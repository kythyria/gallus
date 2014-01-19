=begin comment
WBXML to XML parser. Vaguely like wbxml2xml in the libwbxml package, except that
it generates more useful names for unknown tags and is hardcoded to
Skype-flavoured activesync.

Takes a single argument naming a file containing WBXML, and writes XML
corresponding to that file to stdout.
=end

require 'rexml/document'
require 'pry'

module Wbxml
    # Global tokens
    SWITCH_PAGE = 0x0
    END_T       = 0x1 # END on its own is a reserved word
    ENTITY      = 0x2
    STR_I       = 0x3
    LITERAL     = 0x4
    EXT_I_0     = 0x40
    EXT_I_1     = 0x41
    EXT_I_2     = 0x42
    PI          = 0x43
    LITERAL_C   = 0x44
    EXT_T_0     = 0x80
    EXT_T_1     = 0x81
    EXT_T_2     = 0x82
    STR_T       = 0x83
    LITERAL_A   = 0x84
    EXT_0       = 0xC0
    EXT_1       = 0xC1
    EXT_2       = 0xC2
    OPAQUE      = 0xC3
    LITERAL_AC  = 0xC4
    
    # Public Identifiers
    PUBLICID = [
        "LITERAL",
        "UNKNOWN",
        "-//WAPFORUM//DTD WML 1.0//EN",
        "-//WAPFORUM//DTD WTA 1.0//EN",
        "-//WAPFORUM//DTD WML 1.1//EN",
        "-//WAPFORUM//DTD SI 1.0//EN",
        "-//WAPFORUM//DTD SL 1.0//EN",
        "-//WAPFORUM//DTD CO 1.0//EN",
        "-//WAPFORUM//DTD CHANNEL 1.1//EN",
        "-//WAPFORUM//DTD WML 1.2//EN",
        "-//WAPFORUM//DTD WML 1.3//EN",
        "-//WAPFORUM//DTD PROV 1.0//EN",
        "-//WAPFORUM//DTD WTA-WML 1.2//EN",
        "-//WAPFORUM//DTD CHANNEL 1.2//EN"
    ]
    ((PUBLICID.length)..0x7F).each { |i| PUBLICID[i] = sprintf("wbxml:unk_0x%02X",i) }
    
    CHARSET = {3=>"US-ASCII", 4=>"ISO_8859-1:1987", 5=>"ISO_8859-2:1987", 6=>"ISO_8859-3:1988", 7=>"ISO_8859-4:1988", 8=>"ISO_8859-5:1988", 9=>"ISO_8859-6:1987",
               10=>"ISO_8859-7:1987", 11=>"ISO_8859-8:1988", 12=>"ISO_8859-9:1989", 13=>"ISO-8859-10", 14=>"ISO_6937-2-add", 15=>"JIS_X0201", 16=>"JIS_Encoding",
               17=>"Shift_JIS", 18=>"Extended_UNIX_Code_Packed_Format_for_Japanese", 19=>"Extended_UNIX_Code_Fixed_Width_for_Japanese", 20=>"BS_4730",
               21=>"SEN_850200_C", 22=>"IT", 23=>"ES", 24=>"DIN_66003", 25=>"NS_4551-1", 26=>"NF_Z_62-010", 27=>"ISO-10646-UTF-1", 28=>"ISO_646.basic:1983",
               29=>"INVARIANT", 30=>"ISO_646.irv:1983", 31=>"NATS-SEFI", 32=>"NATS-SEFI-ADD", 33=>"NATS-DANO", 34=>"NATS-DANO-ADD", 35=>"SEN_850200_B",
               36=>"KS_C_5601-1987", 37=>"ISO-2022-KR", 38=>"EUC-KR", 39=>"ISO-2022-JP", 40=>"ISO-2022-JP-2", 41=>"JIS_C6220-1969-jp", 42=>"JIS_C6220-1969-ro",
               43=>"PT", 44=>"greek7-old", 45=>"latin-greek", 46=>"NF_Z_62-010_(1973)", 47=>"Latin-greek-1", 48=>"ISO_5427", 49=>"JIS_C6226-1978",
               50=>"BS_viewdata", 51=>"INIS", 52=>"INIS-8", 53=>"INIS-cyrillic", 54=>"ISO_5427:1981", 55=>"ISO_5428:1980", 56=>"GB_1988-80", 57=>"GB_2312-80",
               58=>"NS_4551-2", 59=>"videotex-suppl", 60=>"PT2", 61=>"ES2", 62=>"MSZ_7795.3", 63=>"JIS_C6226-1983", 64=>"greek7", 65=>"ASMO_449", 66=>"iso-ir-90",
               67=>"JIS_C6229-1984-a", 68=>"JIS_C6229-1984-b", 69=>"JIS_C6229-1984-b-add", 70=>"JIS_C6229-1984-hand", 71=>"JIS_C6229-1984-hand-add",
               72=>"JIS_C6229-1984-kana", 73=>"ISO_2033-1983", 74=>"ANSI_X3.110-1983", 75=>"T.61-7bit", 76=>"T.61-8bit", 77=>"ECMA-cyrillic",
               78=>"CSA_Z243.4-1985-1", 79=>"CSA_Z243.4-1985-2", 80=>"CSA_Z243.4-1985-gr", 81=>"ISO_8859-6-E", 82=>"ISO_8859-6-I", 83=>"T.101-G2",
               84=>"ISO_8859-8-E", 85=>"ISO_8859-8-I", 86=>"CSN_369103", 87=>"JUS_I.B1.002", 88=>"IEC_P27-1", 89=>"JUS_I.B1.003-serb", 90=>"JUS_I.B1.003-mac",
               91=>"greek-ccitt", 92=>"NC_NC00-10:81", 93=>"ISO_6937-2-25", 94=>"GOST_19768-74", 95=>"ISO_8859-supp", 96=>"ISO_10367-box", 97=>"latin-lap",
               98=>"JIS_X0212-1990", 99=>"DS_2089", 100=>"us-dk", 101=>"dk-us", 102=>"KSC5636", 103=>"UNICODE-1-1-UTF-7", 104=>"ISO-2022-CN",
               105=>"ISO-2022-CN-EXT", 106=>"UTF-8", 109=>"ISO-8859-13", 110=>"ISO-8859-14", 111=>"ISO-8859-15", 112=>"ISO-8859-16", 113=>"GBK", 114=>"GB18030",
               115=>"OSD_EBCDIC_DF04_15", 116=>"OSD_EBCDIC_DF03_IRV", 117=>"OSD_EBCDIC_DF04_1", 118=>"ISO-11548-1", 119=>"KZ-1048", 1000=>"ISO-10646-UCS-2",
               1001=>"ISO-10646-UCS-4", 1002=>"ISO-10646-UCS-Basic", 1003=>"ISO-10646-Unicode-Latin1", 1004=>"ISO-10646-J-1", 1005=>"ISO-Unicode-IBM-1261",
               1006=>"ISO-Unicode-IBM-1268", 1007=>"ISO-Unicode-IBM-1276", 1008=>"ISO-Unicode-IBM-1264", 1009=>"ISO-Unicode-IBM-1265", 1010=>"UNICODE-1-1",
               1011=>"SCSU", 1012=>"UTF-7", 1013=>"UTF-16BE", 1014=>"UTF-16LE", 1015=>"UTF-16", 1016=>"CESU-8", 1017=>"UTF-32", 1018=>"UTF-32BE",
               1019=>"UTF-32LE", 1020=>"BOCU-1", 2000=>"ISO-8859-1-Windows-3.0-Latin-1", 2001=>"ISO-8859-1-Windows-3.1-Latin-1",
               2002=>"ISO-8859-2-Windows-Latin-2", 2003=>"ISO-8859-9-Windows-Latin-5", 2004=>"hp-roman8", 2005=>"Adobe-Standard-Encoding", 2006=>"Ventura-US",
               2007=>"Ventura-International", 2008=>"DEC-MCS", 2009=>"IBM850", 2012=>"PC8-Danish-Norwegian", 2013=>"IBM862", 2014=>"PC8-Turkish",
               2015=>"IBM-Symbols", 2016=>"IBM-Thai", 2017=>"HP-Legal", 2018=>"HP-Pi-font", 2019=>"HP-Math8", 2020=>"Adobe-Symbol-Encoding", 2021=>"HP-DeskTop",
               2022=>"Ventura-Math", 2023=>"Microsoft-Publishing", 2024=>"Windows-31J", 2025=>"GB2312", 2026=>"Big5", 2027=>"macintosh", 2028=>"IBM037",
               2029=>"IBM038", 2030=>"IBM273", 2031=>"IBM274", 2032=>"IBM275", 2033=>"IBM277", 2034=>"IBM278", 2035=>"IBM280", 2036=>"IBM281", 2037=>"IBM284",
               2038=>"IBM285", 2039=>"IBM290", 2040=>"IBM297", 2041=>"IBM420", 2042=>"IBM423", 2043=>"IBM424", 2011=>"IBM437", 2044=>"IBM500", 2045=>"IBM851",
               2010=>"IBM852", 2046=>"IBM855", 2047=>"IBM857", 2048=>"IBM860", 2049=>"IBM861", 2050=>"IBM863", 2051=>"IBM864", 2052=>"IBM865", 2053=>"IBM868",
               2054=>"IBM869", 2055=>"IBM870", 2056=>"IBM871", 2057=>"IBM880", 2058=>"IBM891", 2059=>"IBM903", 2060=>"IBM904", 2061=>"IBM905", 2062=>"IBM918",
               2063=>"IBM1026", 2064=>"EBCDIC-AT-DE", 2065=>"EBCDIC-AT-DE-A", 2066=>"EBCDIC-CA-FR", 2067=>"EBCDIC-DK-NO", 2068=>"EBCDIC-DK-NO-A",
               2069=>"EBCDIC-FI-SE", 2070=>"EBCDIC-FI-SE-A", 2071=>"EBCDIC-FR", 2072=>"EBCDIC-IT", 2073=>"EBCDIC-PT", 2074=>"EBCDIC-ES", 2075=>"EBCDIC-ES-A",
               2076=>"EBCDIC-ES-S", 2077=>"EBCDIC-UK", 2078=>"EBCDIC-US", 2079=>"UNKNOWN-8BIT", 2080=>"MNEMONIC", 2081=>"MNEM", 2082=>"VISCII", 2083=>"VIQR",
               2084=>"KOI8-R", 2085=>"HZ-GB-2312", 2086=>"IBM866", 2087=>"IBM775", 2088=>"KOI8-U", 2089=>"IBM00858", 2090=>"IBM00924", 2091=>"IBM01140",
               2092=>"IBM01141", 2093=>"IBM01142", 2094=>"IBM01143", 2095=>"IBM01144", 2096=>"IBM01145", 2097=>"IBM01146", 2098=>"IBM01147", 2099=>"IBM01148",
               2100=>"IBM01149", 2101=>"Big5-HKSCS", 2102=>"IBM1047", 2103=>"PTCP154", 2104=>"Amiga-1251", 2105=>"KOI7-switched", 2106=>"BRF", 2107=>"TSCII",
               2108=>"CP51932", 2109=>"windows-874", 2250=>"windows-1250", 2251=>"windows-1251", 2252=>"windows-1252", 2253=>"windows-1253",
               2254=>"windows-1254", 2255=>"windows-1255", 2256=>"windows-1256", 2257=>"windows-1257", 2258=>"windows-1258", 2259=>"TIS-620", 2260=>"CP50220"}
    CHARSET.default_proc = proc { |h,k| sprintf("unknown-charset-0x%04X",k) }
    
    TAGNAMES = {}
    
    class PresharedStringTable
        def initialize(parent, data)
            @arrays = false
            @parent = parent
            @data = data
        end
        
        def [](pagenum, item)
            out = sprintf("unknown:%02X-%02X", pagenum, item)
            pg = @data[pagenum]
            if pg
                out = sprintf("unknown:%s-%02X", pg[:name], item) if pg[:name]
                if pg[item]
                    out = pg[item]
                end
            else
                if @parent
                    out = @parent[pagenum, item]
                end
            end
            if @arrays
                out = [out, ""] unless out.is_a? Array
            end
            return out
        end
    end
    
    class PresharedAttributeTable < PresharedStringTable
        def initialize(parent, data)
            super(parent, data)
            @arrays = true
        end
    end
    
    DEFAULT_TAGS = PresharedStringTable.new(nil, {})
    
    ACTIVESYNC_TAGS = PresharedStringTable.new(nil, {
        0x00 => {
            :name => "AirSync",
            0x05 => 'Sync',
            0x06 => 'Responses',
            0x07 => 'Add',
            0x08 => 'Change',
            0x09 => 'Delete',
            0x0A => 'Fetch',
            0x0B => 'SyncKey',
            0x0C => 'ClientId',
            0x0D => 'ServerId',
            0x0E => 'Status',
            0x0F => 'Collection',
            0x10 => 'Class',
            0x12 => 'CollectionId',
            0x13 => 'GetChanges',
            0x14 => 'MoreAvailable',
            0x15 => 'WindowSize',
            0x16 => 'Commands',
            0x17 => 'Options',
            0x18 => 'FilterType',
            0x1B => 'Conflict',
            0x1C => 'Collections',
            0x1D => 'ApplicationData',
            0x1E => 'DeletesAsMoves',
            0x20 => 'Supported',
            0x21 => 'SoftDelete',
            0x22 => 'MIMESupport',
            0x23 => 'MIMETruncation',
            0x24 => 'Wait',
            0x25 => 'Limit',
            0x26 => 'Partial',
            0x27 => 'ConversationMode',
            0x28 => 'MaxItems',
            0x29 => 'HeartbeatInterval'
        },
        0x01 => {
            :name => "Contacts",
            0x05 => 'Anniversary',
            0x06 => 'AssistantName',
            0x07 => 'AssistantPhoneNumber',
            0x08 => 'Birthday',
            0x0C => 'Business2PhoneNumber',
            0x0D => 'BusinessAddressCity',
            0x0E => 'BusinessAddressCountry',
            0x0F => 'BusinessAddressPostalCode',
            0x10 => 'BusinessAddressState',
            0x11 => 'BusinessAddressStreet',
            0x12 => 'BusinessFaxNumber',
            0x13 => 'BusinessPhoneNumber',
            0x14 => 'CarPhoneNumber',
            0x15 => 'Categories',
            0x16 => 'Category',
            0x17 => 'Children',
            0x18 => 'Child',
            0x19 => 'CompanyName',
            0x1A => 'Department',
            0x1B => 'Email1Address',
            0x1C => 'Email2Address',
            0x1D => 'Email3Address',
            0x1E => 'FileAs',
            0x1F => 'FirstName',
            0x20 => 'Home2PhoneNumber',
            0x21 => 'HomeAddressCity',
            0x22 => 'HomeAddressCountry',
            0x23 => 'HomeAddressPostalCode',
            0x24 => 'HomeAddressState',
            0x25 => 'HomeAddressStreet',
            0x26 => 'HomeFaxNumber',
            0x27 => 'HomePhoneNumber',
            0x28 => 'JobTitle',
            0x29 => 'LastName',
            0x2A => 'MiddleName',
            0x2B => 'MobilePhoneNumber',
            0x2C => 'OfficeLocation',
            0x2D => 'OtherAddressCity',
            0x2E => 'OtherAddressCountry',
            0x2F => 'OtherAddressPostalCode',
            0x30 => 'OtherAddressState',
            0x31 => 'OtherAddressStreet',
            0x32 => 'PagerNumber',
            0x33 => 'RadioPhoneNumber',
            0x34 => 'Spouse',
            0x35 => 'Suffix',
            0x36 => 'Title',
            0x37 => 'WebPage',
            0x38 => 'YomiCompanyName',
            0x39 => 'YomiFirstName',
            0x3A => 'YomiLastName',
            0x3C => 'Picture',
            0x3D => 'Alias',
            0x3E => 'WeightedRank'
        },
        0x07 => {
            :name => "FolderHierarchy",
            0x07 => 'DisplayName',
            0x08 => 'ServerId',
            0x09 => 'ParentId',
            0x0A => 'Type',
            0x0C => 'Status',
            0x0E => 'Changes',
            0x0F => 'Add',
            0x10 => 'Delete',
            0x11 => 'Update',
            0x12 => 'SyncKey',
            0x13 => 'FolderCreate',
            0x14 => 'FolderDelete',
            0x15 => 'FolderUpdate',
            0x16 => 'FolderSync',
            0x17 => 'Count'
        },
        0x0C => {
            :name => "Contacts2",
            0x05 => 'CustomerId',
            0x06 => 'GovernmentId',
            0x07 => 'IMAddress',
            0x08 => 'IMAddress2',
            0x09 => 'IMAddress3',
            0x0A => 'ManagerName',
            0x0B => 'CompanyMainPhone',
            0x0C => 'AccountName',
            0x0D => 'NickName',
            0x0E => 'MMS'
        }
    })
    
    class InlineStringTable
        @ends = []
        @tab = ""
        
        def initialize(str)
            # TODO make this work with multibyte encodings.
            @tab = str
            (0..(@tab.length-1)).each{|i| @ends << i if str[i] == "\x00"}
        end
        
        def [](offset)
            endoffset = @ends[@ends.index{|i| i > offset }] - 1 # avoid the terminator
            @tab[offset..endoffset]
        end
    end
    
    class Parser
        def get_tag_name(num)
            @tag_table[@stag_codepage, num]
        end
        
        def parse(io, tag_table, attr_table)
            @io = io
            @doc = REXML::Document.new
            @currentnode = @doc
            @in_ver = parse_version
            @in_doctype = parse_doctype
            @in_encoding = parse_charset
            @stringtable = parse_stringtable
            @tag_table = tag_table
            
            @attr_codepage = 0
            @stag_codepage = 0
            
            content_parse_loop
            
            @doc
        end
        
        def parse_version
            byte = readbyte
            major = ((byte & 0xF0) >> 4) + 1
            minor = byte & 0x0F
            sprintf("%i.%i", major, minor)
        end
        
        def parse_doctype
            num = parse_mbint
            if num > 0
                return PUBLICID[num]
            else
                return parse_mbint
            end
        end
        
        def parse_charset
            num = parse_mbint
            CHARSET[num]
        end
        
        def parse_stringtable
            InlineStringTable.new(readstring)
        end
        
        def parse_mbint
            out = 0
            i = 0
            begin
                i = readbyte
                out = out << 7
                out += i & 0x7F
            end until i < 127
            out
        end
        
        def readbyte
            b = @io.read(1)
            if b == nil || b == ""
                return nil
            else
                return b.unpack("C")[0]
            end
        end
        
        def readstring
            length = parse_mbint
            @io.read(length)
        end
        
        def readntstring
            str = ""
            while true
                s = readbyte
                break if s == 0 || s == nil
                str << s
            end
            str.force_encoding(@in_encoding)
        end
        
        def content_parse_loop
            while tok = readbyte
                #begin
                if tok == END_T
                    @currentnode = @currentnode.parent
                    if !@currentnode
                        break
                    end
                elsif tok == SWITCH_PAGE
                    @stag_codepage = readbyte
                elsif tok == OPAQUE
                    parse_opaque
                elsif tok == PI
                    list = parse_attrlist
                    pi = REXML::Instruction.new(list[0][0], list[0][1])
                    @currentnode << pi
                elsif tok == ENTITY
                    @currentnode.add_text("" << parse_mbint)
                elsif tok == EXT_0
                    @currentnode << mk_ext_el(0)
                elsif tok == EXT_1
                    @currentnode << mk_ext_el(1)
                elsif tok == EXT_2
                    @currentnode << mk_ext_el(2)
                elsif tok == EXT_I_0
                    @currentnode << mk_ext_el(0, readntstring)
                elsif tok == EXT_I_1
                    @currentnote << mk_ext_el(1, readntstring)
                elsif tok == EXT_I_2
                    @currentnote << mk_ext_el(2, readntstring)
                elsif tok == EXT_T_0
                    @currentnote << mk_ext_el(0, parse_mbint)
                elsif tok == EXT_T_1
                    @currentnote << mk_ext_el(1, parse_mbint)
                elsif tok == EXT_T_2
                    @currentnote << mk_ext_el(2, parse_mbint)
                elsif tok == STR_I
                    @currentnode.add_text readntstring
                elsif tok == STR_T
                    @currentnode.add_text @stringtable[parse_mbint]
                else # It's a tag
                    has_attrs = (tok & 0x80) != 0
                    has_content = (tok & 0x40) != 0
                    name = ""
                    if (tok & 0x3F) == LITERAL
                        name = @stringtable[parse_mbint]
                    else
                        name = get_tag_name(tok & 0x3F)
                    end
                    el = REXML::Element.new(name)
                    if has_attrs
                        attrs = parse_attrlist
                        attrs.each { |n,v| el.attributes[n] = v }
                    end
                    @currentnode << el
                    if has_content
                        @currentnode = el
                    end
                end
                #rescue
                #    binding.pry
                #end
            end
        end
        
        # Produce a list of [name, value] pairs
        def parse_attrlist
            tok = readbyte
            list = []
            currentname  = nil
            currentvalue = ""
            while tok != END_T
                if tok == SWITCH_PAGE
                    @attr_codepage = readbyte
                elsif tok == STR_I
                    currentvalue += readntstring
                elsif tok == STR_T
                    currentvalue += @stringtable[parse_mbint]
                elsif tok == ENTITY
                    currentvalue << readmbstr
                elsif tok == OPAQUE
                    currentvalue << readstring # TODO: What should we do for opaque in an attribute?
                elsif tok == EXT_0
                    currentvalue << "&wbxml_#{@attr_codepage.to_s 16}_ext0;"
                elsif tok == EXT_1
                    currentvalue << "&wbxml_#{@attr_codepage.to_s 16}_ext1;"
                elsif tok == EXT_2
                    currentvalue << "&wbxml_#{@attr_codepage.to_s 16}_ext2;"
                # TODO: Deal with extension tokens that have a string payload
                elsif tok == LITERAL
                    if currentname
                        list << [currentname, currentvalue]
                    end
                    currentname = @stringtable[parse_mbint]
                    currentvalue = ""
                elsif tok < 128 # ATTRSTART
                    if currentname
                        list << [currentname, currentvalue]
                    end
                    currentname, currentvalue = get_attr_start(tok)
                elsif tok > 128 # ATTRVALUE
                    currentvalue += get_attr_value(tok)
                end
                tok = readbyte
            end
            if currentname
                list << [currentname, currentvale]
            end
            list
        end
        
        def parse_opaque
            #Hack since IDK what XML opaque actually maps on to. It's rather aptly named.
            el = REXML::Element.new("wbxml:opaque")
            text = readstring
            el.add_text(text)
            @currentnode << el
        end
        
        def mk_ext_el(extnum, payload=nil)
            el = REXML::Element.new("wbxml:extension")
            el.attributes["n"] = extnum + (@stag_codepage << 8)
            if payload.is_a? Numeric
                el.attributes["value"] = payload
            elsif payload
                el.add_text payload
            end
            el
        end
    end
end

parser = Wbxml::Parser.new
d = File.open(ARGV[0]) do |f|
    parser.parse(f, Wbxml::ACTIVESYNC_TAGS, Wbxml::PresharedAttributeTable.new(nil, {}))
end
formatter = REXML::Formatters::Pretty.new
formatter.compact = true
formatter.width = 120
formatter.write d, $stdout
puts