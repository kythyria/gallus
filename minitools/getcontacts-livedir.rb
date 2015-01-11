#!/usr/bin/env ruby

require 'json'
require 'net/http'

HOST = "people.directory.live.com"
LOCATION = "/people/abcore?SerializeAs=json&market=en-gb&appid=3C48F07D-DE71-490C-B263-A78CFB1CA351"

state = JSON.parse(File.read("state.json"))

cookies = state["cookies"].select{|i| HOST.end_with? i["domain"]}.map{|i| "#{i["name"]}=#{i["value"]}"}.join("; ")

http = Net::HTTP.new(HOST,443)
http.use_ssl = true

response = http.get(LOCATION, {"Cookie" => cookies})

response.body.slice!("<json>")
response_json = JSON.parse(response.body)

puts JSON.pretty_generate(response_json)