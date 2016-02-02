using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Sharpgallus
{
    public class ReceiveMessageEventArgs : EventArgs
    {

    }

    public class EventPipe
    {
        public delegate void ReceiveMessageHandler(object pipe, EventArgs e);
        public event ReceiveMessageHandler ReceiveMessage;


    }
}
