require 'json'
require 'net/http'
require 'rexml/document'
require 'pry'

$state = JSON.parse(File.read("state.json"), :symbolize_names => true)

AB_ENVELOPE = %q{
<?xml version='1.0' encoding='utf-8'?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">
  <soap:Header>
    <ABApplicationHeader xmlns="http://www.msn.com/webservices/AddressBook">
      <ApplicationId>F6D2794D-501F-443A-ADBE-8F1490FF30FD</ApplicationId>
      <IsMigration>false</IsMigration>
      <PartnerScenario>InviteResponse</PartnerScenario>
    </ABApplicationHeader>
    <ABAuthHeader xmlns="http://www.msn.com/webservices/AddressBook">
      <ManagedGroupRequest>false</ManagedGroupRequest>
      <TicketToken></TicketToken>
    </ABAuthHeader>
  </soap:Header>
  <soap:Body></soap:Body>
</soap:Envelope>
}
def ab_soap_request(action)
    envelope = REXML::Document.new(AB_ENVELOPE)
    REXML::XPath.first(envelope[2], "//TicketToken").add_text $state[:tokens][:contacts][:access_token]
    REXML::XPath.first(envelope[2],"//soap:Body") << action
    
    soapaction = "http://www.msn.com/webservices/AddressBook/" + action.name
    
    req = Net::HTTP::Post.new("/abservice/SharingService.asmx")
    req["Content-Type"] = "text/xml"
    req["SOAPAction"] = soapaction
    
    es = ""
    envelope.write(es)
    envelope.write($stderr,2)
    req.body = es
    
    http = Net::HTTP.new("proxy-blu-people.directory.live.com",443)
    http.use_ssl = true
    http.start do |h|
        res = h.request req
        REXML::Document.new(res.body)
    end
end

act = REXML::Document.new(%q{<FindMembership xmlns="http://www.msn.com/webservices/AddressBook">
      <view>Full</view>
      <expandMembership>true</expandMembership>
    </FindMembership>})[0]

ab_soap_request(act).write($stdout, 2)