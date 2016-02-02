using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace Sharpgallus
{
    [DataContract]
    public class SelfProfile
    {
        [DataMember(Name = "username")]
        public string Username { get; set; }

        [DataMember(IsRequired = false, Name = "firstname")]
        public string FirstName { get; set; }

        [DataMember(IsRequired = false, Name = "lastname")]
        public string LastName { get; set; }

        [DataMember(IsRequired = false, Name = "birthday")]
        public string Birthday { get; set; }

        [DataMember(IsRequired = false, Name = "gender")]
        public string Gender { get; set; }

        [DataMember(IsRequired = false, Name = "language")]
        public string Language { get; set; }

        [DataMember(IsRequired = false, Name = "country")]
        public string Country { get; set; }

        [DataMember(IsRequired = false, Name = "province")]
        public string Province { get; set; }

        [DataMember(IsRequired = false, Name = "city")]
        public string City { get; set; }

        [DataMember(IsRequired = false, Name = "homepage")]
        public string Homepage { get; set; }

        [DataMember(IsRequired = false, Name = "about")]
        public string About { get; set; }

        [DataMember(IsRequired = false, Name = "emails")]
        public List<string> Emails { get; set; }

        [DataMember(IsRequired = false, Name = "jobtitle")]
        public string JobTitle { get; set; }

        [DataMember(IsRequired = false, Name = "phoneMobile")]
        public string PhoneMobile { get; set; }

        [DataMember(IsRequired = false, Name = "phoneHome")]
        public string PhoneHome { get; set; }

        [DataMember(IsRequired = false, Name = "phoneOffice")]
        public string PhoneOffice { get; set; }

        [DataMember(IsRequired = false, Name = "mood")]
        public string Mood { get; set; }

        [DataMember(IsRequired = false, Name = "richMood")]
        public object RichMood { get; set; }

        [DataMember(IsRequired = false, Name = "avatarUrl")]
        public Uri AvatarUrl { get; set; }
    }
}
