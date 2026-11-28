using System.Net;
using MiniHttpServer.Framework.Framework.Abstractions;
using MiniHttpServer.Framework.Framework.Services;

namespace MiniHttpServer.Framework.Framework.Results;

public class FileResult(string filePath, IResourceService resourceService)
{
    public async Task ExecuteAsync(HttpListenerContext context)
    {
        var fileExist = await resourceService.ResolveFile(filePath, context);

        if (!fileExist)
            return;

        await HttpResponseService.FilePush(filePath, context);
    }
}