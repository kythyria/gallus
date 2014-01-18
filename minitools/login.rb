require 'json'
require 'uri'
require 'net/http'
require 'pry'

module Gallus
    
    class MsAccountAuthStrategy
        WL_GETTOKEN = "https://login.live.com/oauth20_token.srf"
        SCOPES = {login: "service::login.skype.com::MBI_SSL",
                  contacts: "service::contacts.msn.com::MBI_SSL",
                  activesync: "service::m.hotmail.com::MBI_SSL",
                  ssl: "service::ssl.live.com::MBI_SSL"}
        
        def get_initial_token
            # TODO: Better place to stash the tokens
            # TODO: Hook this up to login-browserui
            j = JSON.parse(File.read("tokens.json"), :symbolize_names => true)
            j[:initial]
        end
        
        def do_auth()
            @tokens[:initial] = get_initial_token
            
            SCOPES.each do |scopename, scope|
                params = {grant_type: "refresh_token", client_id: CLIENTID, scope: scope, refresh_token: @tokens[:initial][:refresh_token]}
                res = Net::HTTP.post_form(WL_GETTOKEN, params)
                if res.code == 200
                    @tokens[scopename] = JSON.parse(res.body, :symbolize_names => true)
                else
                    $stderr.puts "ERROR: Didn't get 200 from the token getting thingy."
                    binding.pry
                end
            end
            @tokens
        end
    end
end

s = Gallus::MsAccountAuthStrategy.new
t = s.do_auth
$stdout.puts JSON.dump(t)