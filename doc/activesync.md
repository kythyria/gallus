# Skype Activesync
Part of the protocol is documented in the [Exchange Protocol Documentation](http://msdn.microsoft.com/en-us/library/cc425499%28EXCHG.80%29.aspx), however, there's a bunch of extra things that are not.

## URLs
In the [contacts list section](skypenotes.md#contacts-list) it's mentioned that these look like `https://m.hotmail.com/Microsoft-Server-ActiveSync?jAkJBBBTa3lwZS0zMDI2NTQ3Nzk0AAxDbGFzc2ljU2t5cGU=`, and that the base64 involved unpacks to the following hex dump.
```
0000:0000  8C 09 09 04  10 53 6B 79  70 65 2D 33  30 32 36 35  .....Skype-30265
0000:0010  34 37 37 39  34 00 0C 43  6C 61 73 73  69 63 53 6B  47794..ClassicSk
0000:0020  79 70 65                                            ype             
```

According to [\[MS-ASHTTP\]](http://msdn.microsoft.com/en-us/library/ee160227%28v=exchg.80%29.aspx) this decodes as
```
00     Version: 140
01     Command: FolderSync
02-03  Locale: en-US
04     Device ID is 16 bytes long
05-14  Device ID: "Skype-3026547794"
15     No policy key
16     Device type is 12 bytes long
17-20  Device type: "ClassicSkype"
```

## WBXML
ActiveSync uses WBXML for compactness, which relies on pre-shared string tables. Unfortunately, I am not privy to these, so guesswork is employed. wbxml/wbxml2xml.rb renders tag and attribute names for which it lacks the string table into forms like `unknown:XX-YY` where `XX` and `YY` are the page that was current at the time of reading that name and the byte representing the name respectively.

The doctype field in the WBXML documents the activesync server uses is left on the `UNKNOWN` value, but the mimetype indicates that [\[MS-ASWBXML\]](http://msdn.microsoft.com/en-us/library/dd299442\(v=exchg.80\).aspx) describes some of the tokens in use.

## Guesses at the unknown tags
```
Page  Token  Meaning
------------------------
FE    05     PropertyBag
FE    06     Property
FE    07     Name
FE    08     Value
```

Assuming that that table is correct, FE-05 through FE-08 serialise hashtables. In some messages valueless properties are seen, perhaps being some kind of query.

```
Name  Type  Remarks
SID   enum  Seen valueless in the query that starts a full sync.
            Seems to be a type ID.
```

### SID values
The following were seen in a FolderSync result
```
SID    DisplayName
---------------------------
PPL    People
ABCH   Internal Contacts
GBL    Block List
SKYPE  Skype Contacts
WL     WindowsLive Contacts
```

## Process
Start with a FolderSync request.
```XML
<FolderSync>
  <SyncKey>0</SyncKey>
  <unknown:FE-05>
    <unknown:FE-06>
      <unknown:FE-07>SID</unknown:FE-07>
    </unknown:FE-06>
  </unknown:FE-05>
</FolderSync>
```
I guess in this context the unknown fields are requesting the `SID` property to be included in the result. A `SyncKey` of zero seems to mean "I have nothing stored locally, give me everything".