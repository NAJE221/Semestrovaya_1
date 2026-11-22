using System.Net;
using MiniHttpServer.Framework.Framework.Configuration;

namespace MiniHttpServer.Terminal;

public static class TerminalUi
{
    public static void PrintMenu()
    {
        Console.Clear();
        
        WriteColored(""" 
                           ╔══════════════════════════════════════╗
                           ║                                      ║
                           ║          MINI HTTP SERVER            ║
                           ║                                      ║
                           ╠══════════════════════════════════════╣
                           ║                                      ║
                           ║   [1]  START   - Запустить сервер    ║
                           ║   [2]  STOP    - Остановить сервер   ║
                           ║   [3]  EXIT    - Выход               ║
                           ║                                      ║
                           ╚══════════════════════════════════════╝
                          """, ConsoleColor.Yellow);
        
        WriteColored("\nВведите команду: ", ConsoleColor.Green);
    }

    private static void PrintPrefixes(HttpListenerPrefixCollection prefixes, ServerSettings serverSettings)
    {
        foreach (var prefix in prefixes)
        {
            var uriBuilder = new UriBuilder(prefix)
            {
                Path = serverSettings.Path
            };

            Console.WriteLine(uriBuilder.Uri);
        }
    }

    public static void PrintSuccessfulStart(HttpListenerPrefixCollection prefixes , ServerSettings serverSettings)
    {
        Console.Clear();
        WriteColored("Сервер запущен\n", ConsoleColor.Green);
        PrintPrefixes(prefixes , serverSettings);
        WriteColored("Введите команду: ", ConsoleColor.Green);
    }
    
    public static void WriteColored(string text, ConsoleColor color)
    {
        Console.ForegroundColor = color;
        Console.Write(text);
        Console.ResetColor();
    }
}