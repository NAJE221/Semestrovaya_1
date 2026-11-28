using System.Net;
using System.Text;
using MiniHttpServer.Framework.Framework.Abstractions;
using MiniHttpServer.Framework.Framework.Services;

namespace MiniHttpServer.Framework.Framework.Results;

public class HtmlResult(string htmlText) : IHttpResult
{
    private const string ContentType = "text/html; charset=utf-8";

    public async Task ExecuteAsync(HttpListenerContext context)
    {
        ArgumentException.ThrowIfNullOrEmpty(htmlText);

        var htmlByte = Encoding.UTF8.GetBytes(htmlText);

        await HttpResponseService.Push(htmlByte, context.Response, ContentType);
    }
}