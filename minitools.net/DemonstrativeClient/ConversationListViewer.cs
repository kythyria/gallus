using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace DemonstrativeClient
{
    public partial class ConversationListViewer : Form
    {
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
    }
}
