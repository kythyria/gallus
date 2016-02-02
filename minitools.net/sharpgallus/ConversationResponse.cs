using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

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
        public string Count;
    }

    [JsonObject(MemberSerialization = MemberSerialization.OptIn)]
    public class ConversationResponse
    {
        [JsonProperty]
        private SyncedCollectionMetadata _metadata;

        public string BackwardLink { get { return _metadata.BackwardLink; } set { _metadata.BackwardLink = value; } }
        public string ForwardLink  { get { return _metadata.ForwardLink; } set { _metadata.ForwardLink = value; } }
        public string SyncState    { get { return _metadata.SyncState; }   set { _metadata.SyncState = value; } }
        public string Count        { get { return _metadata.Count; } set       { _metadata.Count = value; } }
        
        [JsonProperty]
        public List<ConversationUpdate> Conversations { get; set; }
    }

    public class ConversationUpdate
    {

    }
}
