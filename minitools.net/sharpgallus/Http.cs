using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Sharpgallus
{
    public enum HttpTransactionState
    {
        Created,
        Started,
        RequestSent,
        HeadersReceived,
        Complete,
        Timeout,
        DnsError,
        NetworkError
    }

    public class HttpProgressInfo : EventArgs
    {
        private volatile HttpTransactionState _state;

        public HttpTransactionState State { get { return _state; } set { _state = value; } }
        public Uri Url { get; set; }

        public string Method { get; set; }
        public WebHeaderCollection RequestHeaders { get; set; }
        public JToken RequestBody { get; set; }

        public HttpStatusCode ResponseStatus { get; set; }
        public string ResponseStatusDescription { get; set; }
        public WebHeaderCollection ResponseHeaders { get; set; }
        public JToken ResponseBody { get; set; }

        public DateTime RequestStarted { get; set; }
        public DateTime RequestCompleted { get; set; }
        public DateTime ResponseStarted { get; set; }
        public DateTime ResponseCompleted { get; set; }

        public HttpProgressInfo()
        {
            _state = HttpTransactionState.Created;
        }
    }

    public delegate void HttpProgressEventHandler(object sender, HttpProgressInfo info);

    public class HttpClient
    {
        public event HttpProgressEventHandler RequestProgress;

        public async Task<HttpProgressInfo> ExecuteRequestAsync(string url, Dictionary<string,string> headers = null, string method = "GET", JToken body = null)
        {
            var pi = new HttpProgressInfo();
            pi.RequestHeaders = new WebHeaderCollection();

            var req = WebRequest.CreateHttp(url);
            req.Method = method;

            if (headers != null)
            {
                foreach (var i in headers)
                {
                    req.Headers.Add(i.Key, i.Value);
                    pi.RequestHeaders.Add(i.Key, i.Value);
                }
            }

            pi.RequestBody = body == null ? null : body.DeepClone();
            pi.ResponseStarted = DateTime.UtcNow;
            pi.State = HttpTransactionState.Started;
            OnProgress(pi);

            if (body != null)
            {
                using (var rs = await req.GetRequestStreamAsync())
                using (var sw = new System.IO.StreamWriter(rs))
                {
                    await sw.WriteAsync(body.ToString(Formatting.None));
                }
            }
            
            pi.RequestCompleted = DateTime.UtcNow;
            pi.State = HttpTransactionState.RequestSent;
            OnProgress(pi);

            var res = (HttpWebResponse)await req.GetResponseAsync();

            pi.State = HttpTransactionState.HeadersReceived;
            pi.ResponseStarted = DateTime.UtcNow;
            pi.ResponseStatus = res.StatusCode;
            pi.ResponseStatusDescription = res.StatusDescription;
            pi.ResponseHeaders = res.Headers;
            OnProgress(pi);

            using (var rs = res.GetResponseStream())
            using (var sr = new System.IO.StreamReader(rs, Encoding.UTF8))
            {
                var dataText = await sr.ReadToEndAsync();

                pi.State = HttpTransactionState.Complete;

                if (!string.IsNullOrWhiteSpace(dataText))
                {
                    var tok = JToken.Parse(dataText);
                    pi.ResponseBody = tok;
                }
            }

            OnProgress(pi);

            return pi;
        }

        private void OnProgress(HttpProgressInfo pi)
        {
            var handler = RequestProgress;
            if(handler != null)
            {
                handler(this, pi);
            }
        }
    }
}
