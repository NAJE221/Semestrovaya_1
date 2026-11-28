using System.Net;
using System.Web;
using MiniHttpServer.Framework.Framework.Abstractions;
using MiniHttpServer.Framework.Framework.Factories;
using MiniHttpServer.Framework.Framework.Routing;
using MiniHttpServer.Framework.Framework.Storages;

namespace MiniHttpServer.Framework.Framework.Handlers;

internal class ControllerHandler(
    IResourceService resourceService,
    AppStorage storage) : Handler
{
    public override async Task HandlerRequest(HttpListenerContext context)
    {
        var request = context.Request;

        var path = RouteHelper.NormalizePath(request.Url?.AbsolutePath);
        var routeKey = $"{request.HttpMethod.ToUpper()}|{path}";

        if (!RouteRegistry.RouteDescriptors.TryGetValue(routeKey, out var routeDescriptor))
        {
            await resourceService.SendErrorPage(404, context);
            return;
        }

        var controller = ControllerFactory.Create(routeDescriptor.Controller, context, storage);
        var method = routeDescriptor.Method;

        if (!await resourceService.CheckNull(context, 404, controller, method))
            return;

        var result = method.Invoke(controller, await ParseRequestParameters(routeDescriptor, context));

        if (result is Task task)
            await task;
    }

    private static async Task<object[]> ParseRequestParameters(
        RouteDescriptor routeDescriptor,
        HttpListenerContext context)
    {
        var request = context.Request;
        var methodParams = routeDescriptor.MethodsParams;
        var requestParameters = new object[methodParams.Length];

        if (request.HttpMethod.ToLower() is not ("post" or "put" or "patch"))
            return requestParameters;

        const int maxLengthBody = 16 * 1024;

        if (context.Request.ContentLength64 >= maxLengthBody)
            throw new Exception("Длинна тела запроса слишком большая!");

        using var reader = new StreamReader(request.InputStream, request.ContentEncoding);
        var form = HttpUtility.ParseQueryString(await reader.ReadToEndAsync());

        var values = form.AllKeys
            .Where(key => key is not null && form[key] != "")
            .ToDictionary(key => key!, key => form[key]!);

        for (var i = 0; i < requestParameters.Length; i++)
            requestParameters[i] = methodParams[i].ParameterType == typeof(IReadOnlyDictionary<string, string>)
                ? values
                : form[methodParams[i].Name] ?? string.Empty;

        return requestParameters;
    }
}