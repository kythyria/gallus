module Wbxml
    class PresharedStringTable
        def initialize(parent, data)
            @arrays = false
            @parent = parent
            @data = data
            
            @pages_by_name = @data.map { |k,v| {v[:name] => k } }.reduce({}){|m,v|m.merge! v}
            @tokens_by_name = {}
            @data.each do |pagenum, page|
                page.each do |token, str|
                    if token != :name
                        @tokens_by_name[str] = [pagenum, page]
                    end
                end
            end
            
        end
        
        def pagenum_from_name(name)
            out = @pages_by_name[name]
            if !out && @parent
                out = @parent.pagenum_from_name
            elsif !out && !@parent
                out = name.to_i(16)
            end
            return out
        end
        
        def [](pagenum, item = nil)
            if pagenum.is_a?(Integer) && item.is_a?(Integer)
                return name_from_token(pagenum, item)
            elsif item == nil
                if pagenum.respond_to? :to_s
                    return token_from_name(pagenum)
                end
            else
                raise ArgumentError
            end
        end
        
        def token_from_name(str)
            m = /^unknown:(.*)-([0-9A-F]{2})$/.match(str)
            if m #it's unknown!
                token = m[2].to_i(16)
                page = pagenum_from_name(m[1])
                return [page, token]
            else
                tokens = @strings_by_name[str]
                unless tokens
                    @parent.token_from_name(str)
                end
                return tokens
            end
        end
        
        def name_from_token(pagenum, item)
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
        
        DEFAULT = PresharedStringTable.new(nil, {})
    end
    
    class PresharedAttributeTable < PresharedStringTable
        def initialize(parent, data)
            super(parent, data)
            @arrays = true
        end
        
        DEFAULT = PresharedAttributeTable.new(nil, {})
    end
    
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
    
    class MutableInlineStringTable
        def initialize
            @data = ""
        end
        
        def get_string!(str)
            strn = str + "\x00" # TODO: Make this work with multibyte encodings
            idx = @data.index(strn)
            
            if !index
                idx = @data.length
                @data += strn
            end
            
            return idx
        end
        
        def data
            @data.force_encoding("ASCII-8BIT")
        end
    end
end