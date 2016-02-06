using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Sharpgallus
{
    public interface IPageableResponse<T>
    {
        string BackwardLink { get; }
        string ForwardLink { get; }
        string SyncState { get; }
        int Count { get; }
    }
}
