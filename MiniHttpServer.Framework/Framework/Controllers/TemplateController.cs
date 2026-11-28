using System.Net;
using MiniHttpServer.Framework.Framework.Abstractions;
using MiniHttpServer.Framework.Framework.Results;
using MiniHttpServer.HtmlTemplating.Abstractions;

namespace MiniHttpServer.Framework.Framework.Controllers;

public abstract class TemplateController(
    HttpListenerContext context,
    IHtmlTemplateRenderer renderer,
    IResourceService resourceService) : BaseController(context, resourceService)
{
    protected Task Page<T>(string filePath, T model)
    {
        return new PageResult<T>(renderer, filePath, model).ExecuteAsync(Context);
    }
}