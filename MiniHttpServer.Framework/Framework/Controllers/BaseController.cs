using System.Net;
using MiniHttpServer.Framework.Framework.Abstractions;
using MiniHttpServer.Framework.Framework.Results;

namespace MiniHttpServer.Framework.Framework.Controllers;

public abstract class BaseController(
    HttpListenerContext context,
    IResourceService resourceService)
{
    protected readonly HttpListenerContext Context = context;

    protected Task Html(string text)
    {
        return new HtmlResult(text).ExecuteAsync(Context);
    }

    protected Task Json<T>(T model)
    {
        return new JsonResult<T>(model).ExecuteAsync(Context);
    }

    protected Task File(string filePath)
    {
        return new FileResult(filePath, resourceService).ExecuteAsync(Context);
    }
}