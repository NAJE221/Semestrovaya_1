using System.Net;
using System.Text;

namespace MiniHttpServer.Framework.Framework.Services;

public static class FileService
{
    public static async Task FilePush(string filePath, HttpListenerContext context)
    {
        if (string.IsNullOrEmpty(filePath))
            throw new ArgumentNullException(nameof(filePath));
        
        var buffer = await File.ReadAllBytesAsync(filePath);
        FileInfo fileInfo = new(filePath);
        MimeTypeCheckerService.CheckMimeType(context.Response , fileInfo);
        
        await Push(buffer, context);
    }
    
    public static async Task FilePush(
        byte[] buffer,
        string contentType,
        HttpListenerContext context)
    {
        ArgumentNullException.ThrowIfNull(buffer);
        ArgumentException.ThrowIfNullOrWhiteSpace(contentType);

        context.Response.ContentType = contentType;

        await Push(buffer, context);
    }

    public static async Task StringPush(string text,
        HttpListenerContext context)
    {
        ArgumentNullException.ThrowIfNull(text);
        ArgumentNullException.ThrowIfNull(context);

        var buffer = Encoding.UTF8.GetBytes(text);
        
        await Push(buffer , context);
    }

    private static async Task Push(byte[] buffer , HttpListenerContext context)
    {
        var output = context.Response.OutputStream;
        await output.WriteAsync(buffer);
        await output.FlushAsync();
    }

    public static void StartStream(HttpListenerContext context)
    {
        ArgumentNullException.ThrowIfNull(context);

        context.Response.KeepAlive = true;
        context.Response.SendChunked = true;
    }
    
    public static void StopStream(HttpListenerContext context)
    {
        ArgumentNullException.ThrowIfNull(context);
        context.Response.Close();
    }
}