require 'net/http'
require 'json'
require 'uri'
require 'date'
require 'readline'
require 'io/console'
require 'pry'

def getcookies(response)
    setcookies = response.get_fields("Set-Cookie")
    cookies = []
    setcookies.each do |i|
        cookie_string = i.split(";")
        name, value = cookie_string.shift.split("=")
        value ||= ""
        cookie = {name: name.strip, value: value.strip}
        cookie_string.each do |i|
            name, value = i.split("=")
            case name.strip.downcase
                when "domain" then cookie[:domain] = value.strip.downcase
                when "path" then cookie[:path] = value.strip.downcase
                when "max-age" then cookie[:expirationDate] = Time.now + value.strip.to_i
                when "expires" then cookie[:expirationDate] = DateTime.parse(value.strip).to_time
                when "secure" then cookie[:secure] = true
                when "httponly" then cookie[:httpOnly] = true
            end
        end
        cookies << cookie
    end
    return cookies
end

def post_form(url, headers, content)
    uri = URI.parse(url)
    
    req = Net::HTTP::Post.new(uri)
    headers.each do |k,v|
        req[k.to_s] = v
    end
    
    req.form_data = content
    
    http = Net::HTTP.new(uri.hostname, 443)
    http.use_ssl = true
    http.start do |h|
        h.request req
    end
end

def urlencoded_to_hash(str)
    pairs = str.split("&")
    return pairs.map do |i|
        m = /^([^=]*)=(.*)$/.match i
        {m[1].to_sym => URI.decode(m[2])}
    end.reduce({}){|m,v| m.merge! v}
end

POST_SRF = "https://login.live.com/ppsecure/post.srf"
WL_AUTHSTART = "https://login.live.com/oauth20_authorize.srf"
REDIRECT_URL = "https://login.live.com/oauth20_desktop.srf"
CLIENTID = "00000000480BC46C"
INITIAL_SCOPE = "service::skype.com::MBI_SSL"

startparams = sprintf("?client_id=%s&scope=%s&response_type=token&redirect_uri=%s&state=999&locale=en", # TODO: Set the locale parameter correctly
 URI::encode(CLIENTID),
 URI::encode(INITIAL_SCOPE),
 URI::encode(REDIRECT_URL)
 )
starturl = WL_AUTHSTART + startparams

puts "Login to Skype"

user = Readline.readline("Microsoft account: ", false)
password = $stdin.noecho { buf = Readline.readline("Password: ", false) ; puts ; buf }
puts

puts "Getting login page"
loginpage = Net::HTTP.get_response(URI.parse(starturl))

# Acquire the PPFT
ppft = loginpage.body.split('name="PPFT"')[1].split('value="')[1].split('"/>')[0]
mspok = getcookies(loginpage).select{|i| i[:name] == "MSPOK"}.last[:value]

response = post_form(POST_SRF+startparams, {Cookie: "MSPOK="+mspok}, {PPFT: ppft, login: user, passwd: password})

if response.is_a? Net::HTTPOK
    # This absurd regex roughly matches JS strings. A " or ' followed by any number of characters that are
    # either a backslash followed by anything, or a character that isn't the one that opened the quote, followed
    # by the closing quote.
    m = /sErrTxt:(["'])((?:\\.|(?:(?!\1).))*)\1/.match(response.body)
    msg = m[2]
    msg.gsub!(/<!--.*?-->/,"")
    
    puts "Error: " + msg
    exit 1
end

newstate = {}

dest = response["Location"]
if !(dest && dest.start_with?(REDIRECT_URL))
    puts "Error!"
    puts response.inspect
    binding.pry
end

newstate[:tokens] = { initial: urlencoded_to_hash(URI.parse(dest).fragment) }
newstate[:cookies] = getcookies(response).select{|i|i[:value].length > 0}

File.write("state.json",JSON.pretty_generate(newstate))