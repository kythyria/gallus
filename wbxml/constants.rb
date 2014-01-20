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
    ((PUBLICID.length)..0x7F).each { |i| PUBLICID[i] = sprintf("-//UNKNOWN//0x%02X",i) }
    
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
end