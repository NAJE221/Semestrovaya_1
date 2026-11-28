using System.Net;
using System.Text;
using MiniHttpServer.Framework.Framework.Abstractions;
using MiniHttpServer.Framework.Framework.Services;
using MiniHttpServer.HtmlTemplating.Abstractions;

namespace MiniHttpServer.Framework.Framework.Results;

public class PageResult<T>(
    IHtmlTemplateRenderer renderer,
    string pathTemplate,
    T model) : IHttpResult
{
    private const string ContentType = "text/html";

    public async Task ExecuteAsync(HttpListenerContext context)
    {
        var resultRender = renderer.RenderFromFile(pathTemplate, model);

        var pageByte = Encoding.UTF8.GetBytes(resultRender);

        await HttpResponseService.Push(pageByte, context.Response, ContentType);
    }
}