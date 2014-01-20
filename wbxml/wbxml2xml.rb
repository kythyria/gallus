=begin comment
WBXML to XML parser. Vaguely like wbxml2xml in the libwbxml package, except that
it generates more useful names for unknown tags and is hardcoded to
Skype-flavoured activesync.

Takes a single argument naming a file containing WBXML, and writes XML
corresponding to that file to stdout.
=end

require 'rexml/document'

$LOAD_PATH.unshift File.realpath(__FILE__+"/../..")
require 'wbxml/parser'
require 'wbxml/activesync'

parser = Wbxml::Parser.new
d = File.open(ARGV[0]) do |f|
    parser.parse(f, Wbxml::ACTIVESYNC_TAGS, Wbxml::PresharedAttributeTable.new(nil, {}))
end
formatter = REXML::Formatters::Pretty.new
formatter.compact = true
formatter.width = 120
formatter.write d, $stdout
puts