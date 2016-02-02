using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Sharpgallus
{
    public static class Extensions
    {
        public static long ToUnixTime(this DateTime tim)
        {
            return (long)(tim.ToUniversalTime().Subtract(new DateTime(1970, 01, 01)).TotalSeconds);
        }
    }
}
