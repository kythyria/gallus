# Skype protocol notes

It looks a lot like [msnp21](http://code.google.com/p/msnp-sharp/wiki/KB_MSNP21) with a different login process.

## Login

If you log in with a MS Account, you start (in the MSNP stream) by being referred to as `1:alice@hotmail.co.uk` and end up as something more like `8:live:alice_1`, 8 apparently being the namespace for Skype users. Looks like the [documented](http://msdn.microsoft.com/en-us/library/live/hh243647.aspx#implicitgrant) process for logging in to Windows Live, with scope `service::skype.com::MBI_SSL` (there's mention of ambientssl in later in the MSNP21 parts!) and client ID `00000000480BC46C`

Follow that, eventually you get a redirection to the URL you requested as the callback (Skype requests `https://login.live.com/oauth20_desktop.srf?lc=2033`) with a big fragment and a fuckton of cookies. Note that so long as you use Skype's client ID you pretty much [i]have[/i] to use that URL. WL will complain if you use anything it doesn't like, which is probably any other URL given that Skype is a desktop application.

```
access_token=<lots of base64>
refresh_token=<a bit less base64>
token_type=bearer
expires_in=86400
scope=service::skype.com::MBI_SSL
state=999
user_id=<a bunch of hex> // I guess this is one of the forms of UID that WL uses?
```

Skype then requests `https://api.skype.com/rps/me` with query parameters
```
jsoncallback=<valid JS name>
access_token=<the token we got from l.l.c>
_=<some number>
```
and gets back some JSON wrapped in a call to the function named by `jsoncallback` (optional parameter, leave it out for normal JSON). Guess it's a very basic profile information.
```Javascript
{
  "gender": "m",
  "siteId": 287688,
  "firstName": "REDA",
  "cid": <a bunch of hex>, // same thing l.l.c gave us in user_id
  "siteName": "skype.com",
  "lastName": "CTED",
  "country": "UK",
  "email": <a mail address>, // It's the one I entered during the oauth2 stuff.
  "birthdate": <date in big-endian format> 
}
```

Next up, same sort of query to `https://api.skype.com/partners/999/usermap` except now there's `_accept=1.0` in the query too:
```Javascript
{
  "uid": <hex> , // WL CID again.
  "username": <some string>, // This is important for the MSNP parts.
  "status": "ACTIVE", // Account is enabled?
  "partnerUsername": <email address> // Yeah, this is my WL login name.
}
```
Note that `partnerUsername` and `username` can be related: for me, `live:alice_1` and `alice@hotmail.co.uk` respectively. Interesting that there's a 999 in the URL as well as returned in the first login token.

I guess this is how Skype knows what username to use later on given I entered `partnerUsername` when logging in but `username` is used once logged in.

The `refresh_token` is then used to get more authentication tokens, post to `https://login.live.com/oauth20_token.srf` with urlencoded body
```
grant_type=refresh_token
client_id=00000000480BC46C
scope=<varies>
refresh_token=<the refresh token from login>
```

Not sure what it's for, but the scopes
```
service::login.skype.com::MBI_SSL
service::contacts.msn.com::MBI_SSL
service::m.hotmail.com::MBI_SSL
service::ssl.live.com::MBI_SSL
```
are used.

## Contacts list
Note that `ABFindAll` from MSNP13 doesn't work.

This appears to use a mutant version of exchange activesync. Have a wbxml decoder ready. It also uses SOAP in places. The first request is SOAP to `https://proxy-blu-people.directory.live.com/abservice/SharingService.asmx`, and looks like this:
```XML
<?xml version='1.0' encoding='utf-8'?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" 
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xmlns:xsd="http://www.w3.org/2001/XMLSchema"
               xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">
  <soap:Header>
    <ABApplicationHeader xmlns="http://www.msn.com/webservices/AddressBook">
      <ApplicationId>F6D2794D-501F-443A-ADBE-8F1490FF30FD</ApplicationId>
      <IsMigration>false</IsMigration>
      <PartnerScenario>InviteResponse</PartnerScenario>
      <CacheKey><!-- some long base64 string --></CacheKey>
    </ABApplicationHeader>
    <ABAuthHeader xmlns="http://www.msn.com/webservices/AddressBook">
      <ManagedGroupRequest>false</ManagedGroupRequest>
      <TicketToken><!-- the access_token for service::contacts.msn.com::MBI_SSL --></TicketToken>
    </ABAuthHeader>
  </soap:Header>
  <soap:Body>
    <FindMembershipByRole xmlns="http://www.msn.com/webservices/AddressBook">
      <serviceFilter>
        <Types>
          <ServiceType>Messenger</ServiceType>
        </Types>
      </serviceFilter>
      <includedRoles>
        <RoleId>Pending</RoleId>
      </includedRoles>
      <view>Full</view>
      <expandMembership>true</expandMembership>
    </FindMembershipByRole>
  </soap:Body>
</soap:Envelope>
```

Response:
```XML
<?xml version='1.0' encoding='utf-8'?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soap:Header>
    <ServiceHeader xmlns="http://www.msn.com/webservices/AddressBook">
      <Version>17.3.1483.1118</Version>
      <CacheKeyChanged>false</CacheKeyChanged>
      <PreferredHostName>proxy-blu-people.directory.live.com</PreferredHostName>
      <SessionId>ABCH.a19de4c1-28fa-4432-8c9e-959c5eaba9e7</SessionId>
    </ServiceHeader>
  </soap:Header>
  <soap:Body>
    <FindMembershipByRoleResponse xmlns="http://www.msn.com/webservices/AddressBook">
      <FindMembershipByRoleResult>
        <OwnerNamespace>
          <Info>
            <Handle>
              <Id>00000000-0000-0000-0000-000000000000</Id>
              <IsPassportNameHidden>false</IsPassportNameHidden>
              <CID>0</CID>
            </Handle>
            <CreatorPuid>0</CreatorPuid>
            <CreatorCID><!-- number which is presumaby the CID from above read as a signed integer --></CreatorCID>
            <CreatorPassportName>REDACTED@hotmail.co.uk</CreatorPassportName>
            <CircleAttributes>
              <IsPresenceEnabled>false</IsPresenceEnabled>
              <Domain>None</Domain>
            </CircleAttributes>
            <MessengerApplicationServiceCreated>false</MessengerApplicationServiceCreated>
          </Info>
          <Changes/>
          <CreateDate>2005-09-23T05:56:24.933-07:00</CreateDate>
          <LastChange>2014-01-05T14:12:34.827-08:00</LastChange>
        </OwnerNamespace>
      </FindMembershipByRoleResult>
    </FindMembershipByRoleResponse>
  </soap:Body>
</soap:Envelope>
```
Which is odd. The MSNP21 link above says the address with the zero UUID is used to create groupchats, so it's anyone's guess what that is.

Then begins an ActiveSync conversation; starting by sending to `https://m.hotmail.com/Microsoft-Server-ActiveSync?jAkJBBBTa3lwZS0zMDI2NTQ3Nzk0AAxDbGFzc2ljU2t5cGU=`. That query string is base64 for (in Ruby's string escaping, so "\xnn" is a 0xnn byte) `\x8C\t\t\x04\x10Skype-3026547794\x00\fClassicSkype`. Currently not known exactly how that works; it may or may not be the documented form of activesync. The Authorization header contains "RPSToken", a space, and the access_token for `service::m.hotmail.com::MBI_SSL`

While that's going on, the Skype UI starts loading stuff, and there's another SOAP request, this time to `https://proxy-blu-people.directory.live.com/abservice/abservice.asmx`. The request envelope is the same as the last one, the body is now
```XML
<FindAllBlockedContacts xmlns="http://www.msn.com/webservices/AddressBook"/>
```
With response body
```XML
<FindAllBlockedContactsResponse xmlns="http://www.msn.com/webservices/AddressBook">
  <FindAllBlockedContactsResult/>
</FindAllBlockedContactsResponse>
```
I have no blocked contacts, so I don't know what would go in there.

After that, it's msnp, looks like. Also like the contacts list is only attainable using activesync.

## Misc
The backend doesn't do name translation between Messenger and Skype modes, so you see two different names used for you. One is 1:<ms account name>, the other is the one used for Skype itself.

\/me is represented by adding the user's display name to the beginning of the message, and a header "Skype-EmoteOffset" with the length of that name.

It looks like the Registration and Set-Registration headers are for a cookie.