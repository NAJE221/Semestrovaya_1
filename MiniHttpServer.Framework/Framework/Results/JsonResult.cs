using System.Net;
using System.Text.Json;
using MiniHttpServer.Framework.Framework.Abstractions;
using MiniHttpServer.Framework.Framework.Services;

namespace MiniHttpServer.Framework.Framework.Results;

public class JsonResult<T>(T model) : IHttpResult
{
    private const string ContentType = "application/json; charset=utf-8";

    public async Task ExecuteAsync(HttpListenerContext context)
    {
        ArgumentNullException.ThrowIfNull(model);

        var jsonByte = JsonSerializer.SerializeToUtf8Bytes(model);

        await HttpResponseService.Push(jsonByte, context.Response, ContentType);
    }
}