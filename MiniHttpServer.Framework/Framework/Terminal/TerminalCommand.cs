using System.Net;
using MiniHttpServer.Framework.Framework.Options;

namespace MiniHttpServer.Framework.Framework.Terminal;

public static class TerminalCommand
{
    public static void CommandProcessing(
        HttpListener listener , ServerOptions serverOptions)
    {
        var command = Console.ReadLine()?
            .ToLower()
            .Trim();
        listener.Start();
        switch (command)
        {
            case "start":
                
                if (listener.IsListening)
                    Console.WriteLine("Сервер уже запущен");
                
                else
                    TryStart(listener , serverOptions );
                
                break;
            
            case "stop":
                
                if (!listener.IsListening)
                    Console.WriteLine("Сервер уже остановлен");
                
                else
                {
                    listener.Stop();
                    Console.WriteLine("Сервер остановлен");
                }
                break;
        }
    }

    private static void TryStart(HttpListener listener , ServerOptions serverOptions)
    {
        try
        {
            listener.Start();
            TerminalUi.PrintSuccessfulStart(listener , serverOptions);
        }
        catch (Exception)
        {
            throw new Exception("Проверьте конфигурационный файл. " +
                                "Текущие настройки сервера: " +
                                $"{serverOptions}");
        }
    }
}