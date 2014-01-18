require 'Qt4'
require 'qtwebkit'
require 'uri'
require 'json'

WL_AUTHSTART = "https://login.live.com/oauth20_authorize.srf"
REDIRECT_URL = "https://login.live.com/oauth20_desktop.srf"
CLIENTID = "00000000480BC46C"
INITIAL_SCOPE = "service::skype.com::MBI_SSL"

$starturl = sprintf("%s?client_id=%s&scope=%s&response_type=token&redirect_uri=%s&state=999&locale=en", # TODO: Set the locale parameter correctly
                    WL_AUTHSTART,
                    URI::encode(CLIENTID),
                    URI::encode(INITIAL_SCOPE),
                    URI::encode(REDIRECT_URL)
                   )

urls = []

def urlencoded_to_hash(str)
    pairs = str.split("&")
    return pairs.map do |i|
        m = /^([^=]*)=(.*)$/.match i
        {m[1].to_sym => URI.decode(m[2])}
    end.reduce({}){|m,v| m.merge! v}
end

Qt::Application.new(ARGV) do
    Qt::WebView.new do
        self.load Qt::Url.new($starturl)
        self.connect(SIGNAL('urlChanged(QUrl)')) do |url|
            urls << url.toString
            #Qt::Application.instance.quit if urls.last.start_with? REDIRECT_URL
        end
        show
    end
    exec
end

if urls.last.start_with? REDIRECT_URL
    parmstr = /^[^\#]*\#(.*)$/.match(urls.last)[1]
    puts JSON.dump({status: "success", token: urlencoded_to_hash(parmstr)})
else
    puts %q{{"status": "failure"}}
end