using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using JsonEnumValue = System.Runtime.Serialization.EnumMemberAttribute;

namespace Sharpgallus
{
    [JsonObject]
    public class ContactResponse
    {
        [JsonProperty("contacts")]
        public List<Contact> Contacts;

        [JsonProperty("count")]
        int Count;

        [JsonProperty("scope")]
        string Scope;
    }

    /*    authorized   : bool
    avatar_url   : string uri
    blocked      : bool
    display_name : string
    id           : string
    locations    : object[]
    name         : object { first? nickname? last? }
    phones       : object[] { number : string msisdn, type : int enum }
    suggested    : bool
    type         : string enum { skype, msn, pstn, agent, ... }
    */

    [JsonObject]
    public class ContactLocation
    {
        [JsonProperty("country")]
        string Country { get; set; }

        [JsonProperty("city")]
        string City { get; set; }

        [JsonProperty("province")]
        string Province { get; set; }
    }

    [JsonObject]
    public class ContactName
    {
        [JsonProperty("first")]
        string First { get; set; }

        [JsonProperty("surname")]
        string Surname { get; set; }

        [JsonProperty("nickname")]
        string Nickname { get; set; }
    }

    [JsonObject]
    public class ContactTelephoneEntry
    {
        [JsonProperty("number")]
        string Number { get; set; }

        [JsonProperty("type")]
        int Type { get; set; }

    }

    public enum ContactType
    {
        [JsonEnumValue(Value = "skype")]
        Skype,

        [JsonEnumValue(Value = "msn")]
        MSN,

        [JsonEnumValue(Value = "pstn")]
        PSTN,

        [JsonEnumValue(Value = "agent")]
        Agent
    }

    [JsonObject]
    public class Contact
    {
        [JsonProperty("authorized")]
        public bool Authorized { get; set; }

        [JsonProperty("avatar_url")]
        public Uri AvatarUrl { get; set; }

        [JsonProperty("blocked")]
        public bool Blocked { get; set; }

        [JsonProperty("display_name")]
        public string DisplayName { get; set; }

        [JsonProperty("id")]
        public string Username { get; set; }

        [JsonProperty("locations")]
        public List<ContactLocation> Locations;

        [JsonProperty("name")]
        public ContactName Name { get; set; }

        [JsonProperty("phones")]
        public List<ContactTelephoneEntry> PhoneNumbers { get; set; }

        [JsonProperty("suggested")]
        public bool suggested { get; set; }

        [JsonProperty("type")]
        public ContactType Type { get; set; }

        public override string ToString()
        {
            return string.Format("{{SkypeContact: {0}}}", Username);
        }
    }
}
