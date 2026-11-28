using System.Net;
using MiniHttpServer.Framework.Framework.Abstractions;
using MiniHttpServer.Framework.Framework.Configuration;
using MiniHttpServer.Framework.Framework.Factories;
using MiniHttpServer.Framework.Framework.Handlers;
using MiniHttpServer.Framework.Framework.Routing;
using MiniHttpServer.Framework.Framework.Services;
using MiniHttpServer.Framework.Framework.Storages;

namespace MiniHttpServer.Framework.Framework;

public class FrameworkBuilder
{
    public readonly HttpServer Server;

    private FrameworkBuilder(ServerSettings serverSettings, AppStorage storage)
    {
        RouteRegistry.Register();

        var listener = new HttpListener();

        IResourceService resourceService = new ResourceService();

        Handler controllerHandler = new ControllerHandler(resourceService, storage);
        Handler fileHandler = new StaticFileHandler(resourceService);

        var chain = HandlerChainFactory.AssembleChain(
            fileHandler,
            controllerHandler);

        string prefix;

        if (serverSettings.Host == "+")
        {
            var path = serverSettings.Path?.Trim('/');
            prefix = string.IsNullOrEmpty(path)
                ? $"http://+:{serverSettings.Port}/"
                : $"http://+:{serverSettings.Port}/{path}/";
        }
        else
        {
            prefix = UriFactory.CreateUri(serverSettings).Uri.ToString();
        }

        listener.Prefixes.Add(prefix);

        Server = new HttpServer(listener, chain, serverSettings);
    }

    public static async Task<FrameworkBuilder> CreateBuilder(
        string filePath,
        string sectionName,
        AppStorage storage)
    {
        var settings = await JsonConfigurationLoader.LoadAsync<ServerSettings>(filePath, sectionName);

        return new FrameworkBuilder(settings, storage);
    }
}