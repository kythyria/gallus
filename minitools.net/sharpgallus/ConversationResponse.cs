using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Sharpgallus
{
    [JsonObject]
    class SyncedCollectionMetadata
    {
        [JsonProperty("backwardLink")]
        public string BackwardLink;

        [JsonProperty("forwardLink")]
        public string ForwardLink;

        [JsonProperty("syncState")]
        public string SyncState;

        [JsonProperty("totalCount")]
        public int Count;
    }

    [JsonObject(MemberSerialization = MemberSerialization.OptIn)]
    public class ConversationResponse : IPageableResponse<ConversationResponse>
    {
        [JsonProperty]
        private SyncedCollectionMetadata _metadata;

        public string BackwardLink { get { return _metadata.BackwardLink; } set { _metadata.BackwardLink = value; } }
        public string ForwardLink  { get { return _metadata.ForwardLink; }  set { _metadata.ForwardLink = value; } }
        public string SyncState    { get { return _metadata.SyncState; }    set { _metadata.SyncState = value; } }
        public int    Count        { get { return _metadata.Count; }        set { _metadata.Count = value; } }
        
        [JsonProperty]
        public List<ConversationUpdate> Conversations { get; set; }
    }

    [JsonObject]
    public class ConversationUpdate
    {
        [JsonProperty("id")]
        public string Id { get; set; }

        [JsonProperty("lastMessage")]
        public JObject LastMessage { get; set; }

        [JsonProperty("messages")]
        public Uri Messages { get; set; }

        [JsonProperty("properties")]
        public JObject Properties { get; set; }

        [JsonProperty("targetLink")]
        public Uri TargetLink { get; set; }

        [JsonProperty("type")]
        public string Type { get; set; }

        [JsonProperty("version")]
        public ulong Version { get; set; }

        [JsonProperty("threadProperties")]
        public JObject ThreadProperties { get; set; }
    }
}
