using System.Net;
using MiniHttpServer.Framework.Framework.Abstractions;
using MiniHttpServer.Framework.Framework.Factories;
using MiniHttpServer.Framework.Framework.Handlers;
using MiniHttpServer.Framework.Framework.Options;
using MiniHttpServer.Framework.Framework.Routing;
using MiniHttpServer.Framework.Framework.Services;
using MiniHttpServer.Framework.Framework.Storages;

namespace MiniHttpServer.Framework.Framework;

public class FrameworkBuilder
{
    public readonly HttpServer Server;

    private FrameworkBuilder(ServerOptions serverOptions, AppStorage  storage)
    {
        RouteRegistry.Register();
        
        var listener = new HttpListener();
        
        IResourceService resourceService = new ResourceService();

        Handler controllerHandler = new ControllerHandler(resourceService , storage);
        Handler fileHandler = new StaticFileHandler(resourceService);

        var chain = HandlerChainFactory.AssembleChain(
            fileHandler,
            controllerHandler);

        var prefix = UriFactory.CreateUri(serverOptions).Uri;

       
        listener.Prefixes.Add(prefix.ToString());
            
        Server = new HttpServer(listener , chain , serverOptions);
    }

    public static async Task<FrameworkBuilder> CreateBuilder(
        string filePath, 
        string sectionName, 
        AppStorage storage)
    {
        var options = await ConfigurationLoaderService.Load(filePath, sectionName);

        return new FrameworkBuilder(options , storage);
    }
}