using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Sharpgallus;

namespace DemonstrativeClient
{
    public partial class ConversationListViewer : Form
    {
        public SkypeApi Api { get; set; }

        private ConversationResponse displayedPage;

        public ConversationListViewer()
        {
            InitializeComponent();
        }

        private void ConversationListViewer_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (e.CloseReason != CloseReason.UserClosing) { return; }
            e.Cancel = true;
            Hide();
        }

        private async void btnGetInitial_Click(object sender, EventArgs e)
        {
            var ts = (dtpDate.Value.Date + dtpTime.Value.TimeOfDay);
            var result = await Api.GetConversationView(ts, Convert.ToInt32(nudPageSize.Value));
            setDisplayedPage(result);
        }

        private void setDisplayedPage(ConversationResponse result)
        {
            displayedPage = result;
            listView1.Items.Clear();
            foreach(var i in result.Conversations)
            {
                var item = new ListViewItem();
                item.Text = i.Id;
                item.SubItems.Add(i.Version.ToString());
                if(i.ThreadProperties != null)
                {
                    item.SubItems.Add("Thread");
                }
                else
                {
                    item.SubItems.Add("Conversation");
                }
                if(i.LastMessage != null)
                {
                    item.SubItems.Add((i.LastMessage["content"] ?? "").ToString());
                }
                else
                {
                    item.SubItems.Add("");
                }
                if(i.ThreadProperties != null)
                {
                    item.SubItems.Add(i.ThreadProperties["topic"].ToString());
                }
                else
                {
                    item.SubItems.Add("");
                }
                listView1.Items.Add(item);
            }

            btnGetBack.Enabled = !string.IsNullOrWhiteSpace(result.BackwardLink);
            btnGetSync.Enabled = !string.IsNullOrWhiteSpace(result.SyncState);
            btnGetForward.Enabled = !string.IsNullOrWhiteSpace(result.ForwardLink);
        }

        private async void btnGetBack_Click(object sender, EventArgs e)
        {
            var result = await Api.GetBackwardPage(displayedPage);
            setDisplayedPage(result);
        }

        private async void btnGetSync_Click(object sender, EventArgs e)
        {
            var result = await Api.GetNextSyncPage(displayedPage);
            setDisplayedPage(result);
        }

        private async void btnGetForward_Click(object sender, EventArgs e)
        {
            var result = await Api.GetForwardPage(displayedPage);
            setDisplayedPage(result);
        }
    }
}
