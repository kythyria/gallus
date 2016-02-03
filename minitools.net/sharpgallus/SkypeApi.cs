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
    }
}
