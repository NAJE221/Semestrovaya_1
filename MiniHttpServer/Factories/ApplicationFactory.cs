using System.ComponentModel.Design;
using MiniHttpServer.Framework.Framework;
using MiniHttpServer.Framework.Framework.Services;
using MiniHttpServer.Framework.Framework.Storages;
using MiniHttpServer.HtmlTemplating;
using MiniHttpServer.HtmlTemplating.Abstractions;
using MiniHttpServer.ORM;
using MiniHttpServer.ORM.Abstractions;
using MiniHttpServer.ORM.Driver;
using MiniHttpServer.Repositories;
using MiniHttpServer.Services;

namespace MiniHttpServer.Factories;

public class ApplicationFactory
{
    private async Task<IOrmContext> CreateOrmContext()
    {
        var connectionString = await LoaderDbOptionsService.LoadOptions
            // Путь до конфига и название схемы (DatabaseServerOptions)
            ("server.json", "DatabaseServerOptions");

        IDbDriver driver = new NpgsqlDbDriver(connectionString);

        return new OrmContext(driver);
    }

    private async Task<AppStorage> CreateServiceStorage()
    {
        var context = await CreateOrmContext();

        var storage = new AppStorage();

        var repository = new NpgsqlIiHearthstoneRepository(context);
        IHtmlTemplateRenderer render = new HtmlTemplateRenderer();
        var resourceService = new ResourceService();
        
        storage.Add(repository);
        storage.Add(repository);
        storage.Add(new HearthstoneService(repository, context, render, resourceService));
        
        return storage;
    }

    public async Task<FrameworkBuilder> CreateServerBuilder()
    {
        var storage = await CreateServiceStorage();

        return await FrameworkBuilder.CreateBuilder
            // Путь до конфига и название схемы (Server)
            ("server.json", "Server", storage);
    }
}