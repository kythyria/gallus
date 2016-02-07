namespace DemonstrativeClient
{
    partial class ConversationListViewer
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.label1 = new System.Windows.Forms.Label();
            this.listView1 = new System.Windows.Forms.ListView();
            this.chId = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.chVersion = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.chType = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.chLastMessage = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.chTopic = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.nudPageSize = new System.Windows.Forms.NumericUpDown();
            this.label2 = new System.Windows.Forms.Label();
            this.btnGetInitial = new System.Windows.Forms.Button();
            this.btnGetBack = new System.Windows.Forms.Button();
            this.btnGetSync = new System.Windows.Forms.Button();
            this.btnGetForward = new System.Windows.Forms.Button();
            this.dtpDate = new System.Windows.Forms.DateTimePicker();
            this.dtpTime = new System.Windows.Forms.DateTimePicker();
            ((System.ComponentModel.ISupportInitialize)(this.nudPageSize)).BeginInit();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(9, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(46, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Start TS";
            // 
            // listView1
            // 
            this.listView1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.listView1.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.chId,
            this.chVersion,
            this.chType,
            this.chLastMessage,
            this.chTopic});
            this.listView1.FullRowSelect = true;
            this.listView1.Location = new System.Drawing.Point(12, 32);
            this.listView1.Name = "listView1";
            this.listView1.Size = new System.Drawing.Size(590, 188);
            this.listView1.TabIndex = 2;
            this.listView1.UseCompatibleStateImageBehavior = false;
            this.listView1.View = System.Windows.Forms.View.Details;
            // 
            // chId
            // 
            this.chId.Text = "Id";
            // 
            // chVersion
            // 
            this.chVersion.Text = "Version";
            // 
            // chType
            // 
            this.chType.Text = "Type";
            // 
            // chLastMessage
            // 
            this.chLastMessage.Text = "Last Message";
            this.chLastMessage.Width = 281;
            // 
            // chTopic
            // 
            this.chTopic.Text = "Topic";
            this.chTopic.Width = 95;
            // 
            // nudPageSize
            // 
            this.nudPageSize.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.nudPageSize.Location = new System.Drawing.Point(482, 6);
            this.nudPageSize.Name = "nudPageSize";
            this.nudPageSize.Size = new System.Drawing.Size(120, 20);
            this.nudPageSize.TabIndex = 3;
            this.nudPageSize.Value = new decimal(new int[] {
            2,
            0,
            0,
            0});
            // 
            // label2
            // 
            this.label2.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(425, 9);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(51, 13);
            this.label2.TabIndex = 4;
            this.label2.Text = "pageSize";
            // 
            // btnGetInitial
            // 
            this.btnGetInitial.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnGetInitial.Location = new System.Drawing.Point(12, 226);
            this.btnGetInitial.Name = "btnGetInitial";
            this.btnGetInitial.Size = new System.Drawing.Size(75, 23);
            this.btnGetInitial.TabIndex = 5;
            this.btnGetInitial.Text = "Get Initial";
            this.btnGetInitial.UseVisualStyleBackColor = true;
            this.btnGetInitial.Click += new System.EventHandler(this.btnGetInitial_Click);
            // 
            // btnGetBack
            // 
            this.btnGetBack.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnGetBack.Location = new System.Drawing.Point(93, 226);
            this.btnGetBack.Name = "btnGetBack";
            this.btnGetBack.Size = new System.Drawing.Size(75, 23);
            this.btnGetBack.TabIndex = 6;
            this.btnGetBack.Text = "Get Back";
            this.btnGetBack.UseVisualStyleBackColor = true;
            this.btnGetBack.Click += new System.EventHandler(this.btnGetBack_Click);
            // 
            // btnGetSync
            // 
            this.btnGetSync.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnGetSync.Location = new System.Drawing.Point(174, 226);
            this.btnGetSync.Name = "btnGetSync";
            this.btnGetSync.Size = new System.Drawing.Size(75, 23);
            this.btnGetSync.TabIndex = 7;
            this.btnGetSync.Text = "Get Sync";
            this.btnGetSync.UseVisualStyleBackColor = true;
            this.btnGetSync.Click += new System.EventHandler(this.btnGetSync_Click);
            // 
            // btnGetForward
            // 
            this.btnGetForward.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnGetForward.Location = new System.Drawing.Point(255, 226);
            this.btnGetForward.Name = "btnGetForward";
            this.btnGetForward.Size = new System.Drawing.Size(75, 23);
            this.btnGetForward.TabIndex = 8;
            this.btnGetForward.Text = "Get Forward";
            this.btnGetForward.UseVisualStyleBackColor = true;
            this.btnGetForward.Click += new System.EventHandler(this.btnGetForward_Click);
            // 
            // dtpDate
            // 
            this.dtpDate.Location = new System.Drawing.Point(61, 6);
            this.dtpDate.Name = "dtpDate";
            this.dtpDate.Size = new System.Drawing.Size(225, 20);
            this.dtpDate.TabIndex = 9;
            // 
            // dtpTime
            // 
            this.dtpTime.Format = System.Windows.Forms.DateTimePickerFormat.Time;
            this.dtpTime.Location = new System.Drawing.Point(292, 6);
            this.dtpTime.Name = "dtpTime";
            this.dtpTime.ShowUpDown = true;
            this.dtpTime.Size = new System.Drawing.Size(127, 20);
            this.dtpTime.TabIndex = 10;
            // 
            // ConversationListViewer
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(614, 261);
            this.Controls.Add(this.dtpTime);
            this.Controls.Add(this.dtpDate);
            this.Controls.Add(this.btnGetForward);
            this.Controls.Add(this.btnGetSync);
            this.Controls.Add(this.btnGetBack);
            this.Controls.Add(this.btnGetInitial);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.nudPageSize);
            this.Controls.Add(this.listView1);
            this.Controls.Add(this.label1);
            this.Name = "ConversationListViewer";
            this.Text = "ConversationViewer";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.ConversationListViewer_FormClosing);
            ((System.ComponentModel.ISupportInitialize)(this.nudPageSize)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ListView listView1;
        private System.Windows.Forms.ColumnHeader chId;
        private System.Windows.Forms.ColumnHeader chVersion;
        private System.Windows.Forms.ColumnHeader chType;
        private System.Windows.Forms.ColumnHeader chLastMessage;
        private System.Windows.Forms.ColumnHeader chTopic;
        private System.Windows.Forms.NumericUpDown nudPageSize;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button btnGetInitial;
        private System.Windows.Forms.Button btnGetBack;
        private System.Windows.Forms.Button btnGetSync;
        private System.Windows.Forms.Button btnGetForward;
        private System.Windows.Forms.DateTimePicker dtpDate;
        private System.Windows.Forms.DateTimePicker dtpTime;
    }
}