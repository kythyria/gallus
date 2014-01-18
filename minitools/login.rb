require 'json'
require 'uri'
require 'net/http'
require 'pry'

WL_GETTOKEN = "https://login.live.com/oauth20_token.srf"
CLIENTID = "00000000480BC46C"
SCOPES = {login: "service::login.skype.com::MBI_SSL",
          contacts: "service::contacts.msn.com::MBI_SSL",
          activesync: "service::m.hotmail.com::MBI_SSL",
          ssl: "service::ssl.live.com::MBI_SSL"}
SKYPE_PROFILE="https://api.skype.com/rps/me"
SKYPE_MAPPER ="https://api.skype.com/partners/999/usermap"

def get_initial_token
    # TODO: Better place to stash the tokens
    # TODO: Hook this up to login-browserui
    j = JSON.parse(File.read("state.json"), :symbolize_names => true)
    j[:initial]
end

def parse_json_response(res)
    if res.code == "200" # Why the heck is this a string?
        return JSON.parse(res.body, :symbolize_names => true)
    else
        $stderr.puts "ERROR: Didn't get 200 from the server."
        binding.pry
    end
end

def do_auth()
    tokens = {}
    tokens[:initial] = get_initial_token
    
    SCOPES.each do |scopename, scope|
        params = {grant_type: "refresh_token", client_id: CLIENTID, scope: scope, refresh_token: tokens[:initial][:refresh_token]}
        res = Net::HTTP.post_form(URI.parse(WL_GETTOKEN), params)
        tokens[scopename] = parse_json_response(res)
    end
    tokens
end

def get_skype_profile(tokens)
    output = {}
    
    profileurl = SKYPE_PROFILE + sprintf("?access_token=%s", URI.encode(tokens[:initial][:access_token]))
    res = Net::HTTP.get_response(URI.parse(profileurl))
    output[:me] = parse_json_response(res)
    
    mapperurl = SKYPE_MAPPER + sprintf("?access_token=%s", URI.encode(tokens[:initial][:access_token]))
    res = Net::HTTP.get_response(URI.parse(mapperurl))
    output[:partnermap] = parse_json_response(res)
    output
end

t = do_auth
t.merge! get_skype_profile(t)

File.open("state.json","w") { |f| f.write(JSON.pretty_generate(t)) }