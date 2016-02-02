using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Newtonsoft.Json;
using Sharpgallus;

namespace DemonstrativeClient
{
    public partial class Form1 : Form
    {
        private Random rand = new Random();

        public Form1()
        {
            InitializeComponent();
        }

        private T ApiGetUrl<T>(string token, string url)
        {
            var req = WebRequest.Create(url);
            req.Headers.Add("X-Skypetoken", token);

            T result;

            using (var response = (HttpWebResponse)req.GetResponse())
            using(var tr = new System.IO.StreamReader(response.GetResponseStream()))
            {
                var json = tr.ReadToEnd();
                result = JsonConvert.DeserializeObject<T>(json, new JsonSerializerSettings { MissingMemberHandling = MissingMemberHandling.Error });
            }

            return result;
        }

        private T MsgrGetUrl<T>(string token, string url)
        {
            var req = WebRequest.Create(url);
            req.Headers.Add("RegistrationToken", string.Format("registrationToken={0}",token));
            req.Headers.Add("ContextId", string.Format("tcid={0}1{1}", DateTime.Now.ToUnixTime(), rand.Next(1,999999)));

            T result;

            using (var response = (HttpWebResponse)req.GetResponse())
            using (var tr = new System.IO.StreamReader(response.GetResponseStream()))
            {
                var json = tr.ReadToEnd();
                result = JsonConvert.DeserializeObject<T>(json, new JsonSerializerSettings { MissingMemberHandling = MissingMemberHandling.Error });
            }

            return result;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            var prof = ApiGetUrl<SelfProfile>(tbxSkypeToken.Text, "https://api.skype.com/users/self/profile");
            tbxUid.Text = prof.Username;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            var contactUrl = string.Format("https://contacts.skype.com/contacts/v1/users/{0}/contacts", tbxUid.Text);
            var contactResponse = ApiGetUrl<ContactResponse>(tbxSkypeToken.Text, contactUrl);
        }

        private void button3_Click(object sender, EventArgs e)
        {
            var req = WebRequest.Create("https://client-s.gateway.messenger.live.com/v1/users/ME/endpoints");
            req.Method = "POST";
            req.Headers.Add("Authentication", string.Format("skypetoken={0}",tbxSkypeToken.Text));
            req.Headers.Add("LockAndKey", LockAndKeyGen.CalculateHeader());

            using (var rs = req.GetRequestStream())
            {
                var bytes = Encoding.ASCII.GetBytes("{\"endpointFeatures\":\"Agent\"}");
                rs.Write(bytes, 0, bytes.Length);
            }

            using (var res = (HttpWebResponse)req.GetResponse())
            {
                var rtheader = res.Headers["Set-RegistrationToken"];
                var resplit = rtheader.Split(';').Select(i => i.TrimStart(' ').Split(new char[] { '=' } ,2));
                tbxRegistrationToken.Text = resplit.First(i => i[0] == "registrationToken")[1];
                tbxEpId.Text = resplit.First(i => i[0] == "endpointId")[1];
            }
        }

        private void button4_Click(object sender, EventArgs e)
        {
            var startTime = DateTime.Now - TimeSpan.FromDays(4); // In the real thing, this needs to be configurable.
            var url = string.Format("https://client-s.gateway.messenger.live.com/v1/users/ME/conversations?startTime={0}&pageSize=100&view=msnp24Equivalent&targetType=Passport%7CSkype%7CLync%7CThread%7CAgent", startTime.ToUnixTime());

            var result = MsgrGetUrl<ConversationResponse>(tbxRegistrationToken.Text, url);

            var s = result.Conversations[0];
            int i = s.LastMessage.id;

            System.Diagnostics.Debugger.Break();
        }

        private void button5_Click(object sender, EventArgs e)
        {

        }
    }
}
