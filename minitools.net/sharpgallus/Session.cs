using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Sharpgallus
{
    public class Session
    {
        public SelfProfile Profile { get; }
        public ContactManager Roster { get; }
        public EventPipe Pipe { get; }
    }

}
