using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace JsAnalyser
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            openFileDialog1.ShowDialog();

            string text;
            using (var sr = new System.IO.StreamReader(openFileDialog1.FileName))
            {
                text = sr.ReadToEnd();
            }

            var parser = new Jint.Parser.JavaScriptParser();
            var t1 = DateTime.Now;
            var ast = parser.Parse(text);
            var t2 = DateTime.Now;
            System.Diagnostics.Debugger.Break();
        }
    }
}
