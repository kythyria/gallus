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
    public partial class HttpVisualiser : Form
    {
        class VisualiserEntry
        {
            public string Url;
            public string Method;
            public string Ordinal;
            public string State;
            public string Body;
        }

        private int requestCount = 0;

        public HttpVisualiser()
        {
            InitializeComponent();
            CreateHandle();
        }

        internal void SubscribeToClient(HttpClient client)
        {
            client.RequestProgress += Client_RequestProgress;
        }

        private void Client_RequestProgress(object sender, HttpProgressInfo info)
        {
            if(info.State == HttpTransactionState.Complete)
            {
                BeginInvoke(new handleProgressInfo(addCompletedTransaction), info);
            }
        }

        private delegate void handleProgressInfo(HttpProgressInfo i);

        private void addCompletedTransaction(HttpProgressInfo info)
        {
            var ve = new VisualiserEntry();
            ve.Url = info.Url.ToString();
            ve.Method = info.Method;
            ve.Ordinal = (requestCount++).ToString();
            ve.State = "C";

            var sb = new StringBuilder();
            sb.AppendFormat("Start: {0:HH:mm:ss.ffff}", info.RequestStarted).AppendLine();
            sb.AppendFormat("  End: {0:HH:mm:ss.ffff}", info.ResponseCompleted).AppendLine();
            sb.AppendLine();
            sb.AppendFormat("{0} {1}", info.Method, info.Url).AppendLine();
            foreach (var i in info.RequestHeaders.AllKeys)
            {
                foreach (var j in info.RequestHeaders.GetValues(i))
                {
                    sb.AppendFormat("{0}:{1}", i, j).AppendLine();
                }
            }
            sb.AppendLine();
            sb.Append(info.RequestBody != null ? info.RequestBody.ToString(Newtonsoft.Json.Formatting.Indented) : "").AppendLine();
            sb.Append("---------------------------------------").AppendLine();
            sb.AppendFormat("{0} {1}", (int)info.ResponseStatus, info.ResponseStatusDescription).AppendLine();
            foreach (var i in info.ResponseHeaders.AllKeys)
            {
                foreach (var j in info.ResponseHeaders.GetValues(i))
                {
                    sb.AppendFormat("{0}:{1}", i, j).AppendLine();
                }
            }
            sb.AppendLine();
            sb.Append(info.ResponseBody != null ? info.ResponseBody.ToString(Newtonsoft.Json.Formatting.Indented) : "").AppendLine();

            ve.Body = sb.ToString();

            var lr = new ListViewItem(new string[] { ve.Ordinal, ve.Method, ve.State, ve.Url });
            lr.Tag = ve;
            lvSummary.Items.Add(lr);
        }

        private void lvSummary_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (lvSummary.SelectedItems.Count > 0)
            {
                tbxDetail.Text = (lvSummary.SelectedItems[0].Tag as VisualiserEntry).Body;
            }
        }

        private void HttpVisualiser_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (e.CloseReason != CloseReason.UserClosing) { return; }
            e.Cancel = true;
            Hide();
        }
    }
}
