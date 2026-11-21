using MiniHttpServer.Factories;
namespace MiniHttpServer;

public class ApplicationBuilder
{
    public async Task Build()
    {
        var factory = new ApplicationFactory();

        var builder = await factory.CreateServerBuilder();

        await builder.Server.RunAsync();
    }
}