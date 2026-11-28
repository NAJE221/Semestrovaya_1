using System.Net;

namespace MiniHttpServer.Framework.Framework.Abstractions;

public interface IHttpResult
{
    public Task ExecuteAsync(HttpListenerContext context);
}