require 'rexml/document'

require 'wbxml/stringtable'
require 'wbxml/constants'

module Wbxml
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