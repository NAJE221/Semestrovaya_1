using MiniHttpServer.Framework.Framework;

namespace MiniHttpServer.Terminal;

public static class TerminalCommand
{
    public static async Task<bool> CommandProcessing(HttpServer server)
    {
        var command = Console.ReadLine()?
            .Trim()
            .ToLowerInvariant();

        switch (command)
        {
            case "1" or "start":
                if (server.Listening)
                {
                    TerminalUi.WriteColored("Сервер уже запущен", ConsoleColor.Red);
                    TerminalUi.WriteColored("Введите команду: ", ConsoleColor.Green);
                }

                else
                {
                    server.Start();
                    TerminalUi.PrintSuccessfulStart(server.Prefixes, server.ServerSettings);
                }

                break;

            case "2" or "stop":
                if (!server.Listening)
                {
                    TerminalUi.WriteColored("Сервер уже остановлен\n", ConsoleColor.Red);
                }


                else
                {
                    await server.StopAsync();
                    Console.WriteLine("\nСервер остановлен");
                }

                await Task.Delay(1000);
                TerminalUi.PrintMenu();
                break;

            case "exit":
                return false;

            default:
                TerminalUi.WriteColored("Неизвестная команда\n", ConsoleColor.Red);
                TerminalUi.WriteColored("Введите команду: ", ConsoleColor.Green);
                break;
        }

        return true;
    }
}