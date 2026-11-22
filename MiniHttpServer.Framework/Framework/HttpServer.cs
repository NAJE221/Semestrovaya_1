using System.Net;
using MiniHttpServer.Framework.Framework.Abstractions;
using MiniHttpServer.Framework.Framework.Configuration;

namespace MiniHttpServer.Framework.Framework;

public class HttpServer (
    HttpListener listener, 
    Handler handler,
    ServerSettings serverSettings)
{
    
    private Task? _listenTask;
    public bool Listening => listener.IsListening;
    
    public readonly HttpListenerPrefixCollection Prefixes = listener.Prefixes; 
    
    public readonly ServerSettings ServerSettings = serverSettings;
    
    public void Start()
    {
        if (Listening) return;
        try
        {
            listener.Start();
        }
        catch (Exception)
        {
            throw new Exception("Проверьте конфигурационный файл. " +
                                "Текущие настройки сервера: " +
                                $"{ServerSettings}");
        }
        _listenTask = ListenAsync();
    }

    public async Task StopAsync()
    {
       if  (!Listening) return;
       
       listener.Stop();
       
       if (_listenTask is not null)
           await _listenTask;
    }

    private async Task ListenAsync()
    {
        while (Listening)
        {
            HttpListenerContext context;
            try
            {
                context = await listener.GetContextAsync();
            }
            catch (Exception ex) when (ex is HttpListenerException or ObjectDisposedException)
            {
                break;                 
            }

            _ = ProcessRequestAsync(context);
        }
    }

    private async Task ProcessRequestAsync(HttpListenerContext context)
    {
        try
        {
            await handler.HandlerRequest(context);
            context.Response.Close();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Ошибка обработки запроса: {ex}");
            TrySendError(context);
        }
    }

    private static void TrySendError(HttpListenerContext context)
    {
        try
        {
            context.Response.StatusCode = 500;
            context.Response.Close();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Не удалось отправить ответ: {ex.Message}");
        }
    }
}