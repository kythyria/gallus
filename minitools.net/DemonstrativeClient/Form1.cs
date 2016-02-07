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
        private HttpClient client;
        private SkypeApi api;
        private HttpVisualiser visualiser;
        private ConversationListViewer convoListViewer;

        public Form1()
        {
            InitializeComponent();
            client = new HttpClient();
            visualiser = new HttpVisualiser();
            visualiser.SubscribeToClient(client);
            convoListViewer = new ConversationListViewer();
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

        private async void button1_Click(object sender, EventArgs e)
        {
            var prof = await api.GetSelfProfile();
            tbxUid.Text = prof.Username;
        }

        private async void button2_Click(object sender, EventArgs e)
        {
            var contactResponse = await api.GetContactList(tbxUid.Text);
            textBox4.AppendText(contactResponse.Contacts.Count.ToString());
        }

        private async void button3_Click(object sender, EventArgs e)
        {
            tbxEpId.Text = await api.CreateEndpoint();
            tbxRegistrationToken.Text = api.RegistrationToken;
        }

        private void button4_Click(object sender, EventArgs e)
        {
            var startTime = DateTime.Now - TimeSpan.FromDays(4); // In the real thing, this needs to be configurable.
            var url = string.Format("https://client-s.gateway.messenger.live.com/v1/users/ME/conversations?startTime={0}&pageSize=100&view=msnp24Equivalent&targetType=Passport%7CSkype%7CLync%7CThread%7CAgent", startTime.ToUnixTime());

            var result = MsgrGetUrl<ConversationResponse>(tbxRegistrationToken.Text, url);

            var s = result.Conversations[0];

            System.Diagnostics.Debugger.Break();
        }

        private void tbxSkypeToken_Leave(object sender, EventArgs e)
        {
            if (api == null)
            {
                api = new SkypeApi(tbxSkypeToken.Text, client);
                convoListViewer.Api = api;
            }
            else
            {
                api.SkypeToken = tbxSkypeToken.Text;
            }
        }

        private void btnShowVisualiser_Click(object sender, EventArgs e)
        {
            visualiser.Show();
        }

        private void btnShowConvos_Click(object sender, EventArgs e)
        {
            convoListViewer.Show();
        }
    }
}
