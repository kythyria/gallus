require 'rexml/document'
require 'wbxml/stringtable'
require 'wbxml/constants'

module Wbxml
    class Writer
        def emptystr
            "".force_encoding("ASCII-8BIT")
        end
        
        def initialize(tag_table, attr_table)
            @tag_table = tag_table
            @attr_table = attr_table
        end
        
        def mk_mbint(num)
            outbuf = []
            begin
                i = num & 0x7F
                outbuf.unshift i
                num = num >> 7
            end until num == 0
            outbuf.pack("C*")
        end
        
        def stringify(doc)
            stringtable = MutableInlineStringTable.new
            outbuf = emptystr
            
            outbuf << WBXML_13
            outbuf << mk_mbint(CHARSET.rassoc("UTF-8"))
            
            publicid = doc.respond_to? :doctype ? (doc.doctype ? doc.doctype.public : "UNKNOWN") : "UNKNOWN"
            publicid_num = PUBLICID.index(publicid)
            if publicid_num
                outbuf << publicid_num
            else
                outbuf << 0x00
                outbuf << mk_mbint(stringtable.get_string!(publicid))
            end
            
            #find the first node to serialise: the XML declaration we don't need and the doctype is already encoded.
            n = doc.first
            while n.class == REXML::XMLDecl || n.class == REXML.DocType
                n = n.next_sibling
            end
            
            body = emptystr
            if n
                stringify_sequence(body, stringtable, n)
            end
            
            outbuf << mk_mbint(stringtable.data.length)
            outbuf << stringtable.data
            outbuf << body
            
            return outbuf
        end
        
        def stringify_sequence(outbuf, stringtable, node)
            while node
                case node
                when REXML::Element
                when REXML::Instruction
                when REXML::Text
                else
                    #nothing
                end
                node = node.next_sibling
            end
        end
    end
end