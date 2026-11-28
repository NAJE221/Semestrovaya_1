using MiniHttpServer.Configuration;
using MiniHttpServer.Framework.Framework;
using MiniHttpServer.Framework.Framework.Configuration;
using MiniHttpServer.Framework.Framework.Services;
using MiniHttpServer.Framework.Framework.Storages;
using MiniHttpServer.HtmlTemplating;
using MiniHttpServer.HtmlTemplating.Abstractions;
using MiniHttpServer.ORM;
using MiniHttpServer.ORM.Abstractions;
using MiniHttpServer.ORM.Driver;
using MiniHttpServer.Repositories;
using MiniHttpServer.Services;
using MiniHttpServer.Terminal;

namespace MiniHttpServer;

public class ApplicationBuilder
{
    private const string SettingsFilePath = "settings.json";

    private const string DbSectionName = "DatabaseServerSettings";
    private const string ServerSectionName = "ServerSettings";

    private async Task<IOrmContext> CreateOrmContext()
    {
        var settings = await JsonConfigurationLoader.LoadAsync<DbSettings>
            // Путь до конфига и название схемы (DatabaseServerSettings)
            (SettingsFilePath, DbSectionName);

        var connectionString = settings.ConnectionString;

        IDbDriver driver = new NpgsqlDbDriver(connectionString);

        return new OrmContext(driver);
    }

    private async Task<AppStorage> CreateServiceStorage()
    {
        var ormContext = await CreateOrmContext();

        var storage = new AppStorage();

        var repository = new CardRepository(ormContext);
        IHtmlTemplateRenderer render = new HtmlTemplateRenderer();
        var resourceService = new ResourceService();

        var cardFilterService = await FilterCardsService.Create(repository, render);
        var cardModalService = new CardModalService(repository, render);

        storage.Add(repository);
        storage.Add(render);
        storage.Add(resourceService);
        storage.Add(cardFilterService);
        storage.Add(cardModalService);

        return storage;
    }

    private async Task<FrameworkBuilder> CreateServerBuilder()
    {
        var storage = await CreateServiceStorage();

        return await FrameworkBuilder.CreateBuilder
            // Путь до конфига и название схемы (Server)
            (SettingsFilePath, ServerSectionName, storage);
    }

    public async Task Build()
    {
        var builder = await CreateServerBuilder();
        var server = builder.Server;

        TerminalUi.PrintMenu();

        await ListenTerminal(server);
    }

    private async Task ListenTerminal(HttpServer server)
    {
        while (true)
        {
            var shouldContinue = await TerminalCommand.CommandProcessing(server);

            if (shouldContinue) continue;

            await server.StopAsync();
            return;
        }
    }
}