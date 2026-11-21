using System.Net;
using MiniHttpServer.Framework.Framework.Options;

namespace MiniHttpServer.Framework.Framework.Terminal;

public static class TerminalUi
{
    public static void PrintMenu()
    {
        Console.Clear();

        Console.ForegroundColor = ConsoleColor.Yellow;
        Console.WriteLine("""
                           ╔══════════════════════════════════════╗
                           ║                                      ║
                           ║          MINI HTTP SERVER            ║
                           ║                                      ║
                           ╠══════════════════════════════════════╣
                           ║                                      ║
                           ║   [1]  START   - Запустить сервер    ║
                           ║   [2]  STOP    - Остановить сервер   ║
                           ║                                      ║
                           ╚══════════════════════════════════════╝
                          """);

        Console.WriteLine();
        Console.ForegroundColor = ConsoleColor.Green;
        Console.Write("Введите команду: ");
        Console.ResetColor();
    }

    private static void PrintPrefixes(HttpListener listener, ServerOptions serverOptions)
    {
        foreach (var prefix in listener.Prefixes)
        {
            var uriBuilder = new UriBuilder(prefix)
            {
                Path = serverOptions.Path
            };

            Console.WriteLine(uriBuilder.Uri);
        }
    }

    public static void PrintSuccessfulStart(HttpListener listener , ServerOptions serverOptions)
    {
        Console.Clear();
        Console.WriteLine("Сервер запущен");
        PrintPrefixes(listener , serverOptions);
    }
}