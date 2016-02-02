using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace BrowserLogin
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void webBrowser1_Navigating(object sender, WebBrowserNavigatingEventArgs e)
        {
            if(e.Url.Host == "web.skype.com" && e.Url.AbsolutePath.Length > 1)
            {
                e.Cancel = true;
                webBrowser1.Stop();

                var tokenatt = webBrowser1.Document.Body.GetAttribute("data-params");
                var token = tokenatt.Split(';')[0];
                textBox1.Text = token;
                Console.WriteLine(token);
            }
        }
    }
}
