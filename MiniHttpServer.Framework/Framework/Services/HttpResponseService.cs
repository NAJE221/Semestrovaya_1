using System.Net;
using MiniHttpServer.Framework.Framework.Content;

namespace MiniHttpServer.Framework.Framework.Services;

public static class HttpResponseService
{
    public static async Task FilePush(
        string filePath,
        HttpListenerContext context)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(filePath);

        var buffer = await File.ReadAllBytesAsync(filePath);

        FileInfo fileInfo = new(filePath);

        var contentType = MimeTypeChecker.CheckMimeType(fileInfo);

        await Push(buffer, context.Response, contentType);
    }

    public static async Task Push(
        byte[] buffer,
        HttpListenerResponse response,
        string contentType)
    {
        response.ContentType = contentType;

        if (!response.SendChunked)
            response.ContentLength64 = buffer.Length;


        var output = response.OutputStream;
        await output.WriteAsync(buffer);
        await output.FlushAsync();
    }

    public static async Task ExecuteStreamAsync<T>(
        HttpListenerContext context,
        Func<Task> func)
    {
        ArgumentNullException.ThrowIfNull(context);
        ArgumentNullException.ThrowIfNull(func);

        context.Response.KeepAlive = true;
        context.Response.SendChunked = true;

        try
        {
            await func();
        }
        finally
        {
            context.Response.Close();
        }
    }
}