using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Sharpgallus
{
    /// <summary>
    /// Low level Skype API. Needs a SkypeToken to start with.
    /// </summary>
    public class SkypeApi
    {
        public HttpClient Client { get; set; }
        public string SkypeToken { get; set; }
        public string RegistrationToken { get; set; }

        private Dictionary<string, string> _skypeTokenHeader;
        private Dictionary<string, string> _registrationTokenHeader;

        public SkypeApi(string token, HttpClient client)
        {
            SkypeToken = token;
            Client = client;
            _skypeTokenHeader = new Dictionary<string, string> { { "X-Skypetoken", token } };
        }

        public async Task<SelfProfile> GetSelfProfile()
        {
            var result = await Client.ExecuteRequestAsync("https://api.skype.com/users/self/profile", _skypeTokenHeader);
            return result.ResponseBody.ToObject<SelfProfile>();
        }

        public async Task<ContactResponse> GetContactList(string uid)
        {
            var contactUrl = string.Format("https://contacts.skype.com/contacts/v1/users/{0}/contacts", uid);
            var result = await Client.ExecuteRequestAsync(contactUrl, _skypeTokenHeader);
            return result.ResponseBody.ToObject<ContactResponse>();
        }

        public async Task<string> CreateEndpoint()
        {
            var headers = new Dictionary<string, string>();
            headers.Add("Authentication", string.Format("skypetoken={0}", SkypeToken));
            headers.Add("LockAndKey", LockAndKeyGen.CalculateHeader());
            var endpointCreatorUrl = "https://client-s.gateway.messenger.live.com/v1/users/ME/endpoints";
            var body = new JObject();
            body.Add("endpointFeatures", "Agent");

            var result = await Client.ExecuteRequestAsync(endpointCreatorUrl, headers, "POST", body);

            var rtheader = result.ResponseHeaders["Set-RegistrationToken"];
            var resplit = rtheader.Split(';').Select(i => i.TrimStart(' ').Split(new char[] { '=' }, 2));
            RegistrationToken = resplit.First(i => i[0] == "registrationToken")[1];
            _registrationTokenHeader = new Dictionary<string, string> { { "RegistrationToken", "registrationToken=" + RegistrationToken } };
            return resplit.First(i => i[0] == "endpointId")[1];
        }

        public async Task<ConversationResponse> GetConversationView(DateTime startTime, int pageSize = 100)
        {
            var urlFormat = "https://client-s.gateway.messenger.live.com/v1/users/ME/conversations?startTime={0}&pageSize={1}&view=msnp24Equivalent&targetType=Passport%7CSkype%7CLync%7CThread%7CAgent";
            var url = string.Format(urlFormat, startTime.ToUnixTime(), pageSize);

            var result = await Client.ExecuteRequestAsync(url, _registrationTokenHeader);
            return result.ResponseBody.ToObject<ConversationResponse>();
        }

        public async Task<T> GetBackwardPage<T>(IPageableResponse<T> current)
        {
            var result = await Client.ExecuteRequestAsync(current.BackwardLink, _registrationTokenHeader);
            return result.ResponseBody.ToObject<T>();
        }

        public async Task<T> GetForwardPage<T>(IPageableResponse<T> current)
        {
            var result = await Client.ExecuteRequestAsync(current.ForwardLink, _registrationTokenHeader);
            return result.ResponseBody.ToObject<T>();
        }

        public async Task<T> GetNextSyncPage<T>(IPageableResponse<T> current)
        {
            var result = await Client.ExecuteRequestAsync(current.SyncState, _registrationTokenHeader);
            return result.ResponseBody.ToObject<T>();
        }
    }
}
