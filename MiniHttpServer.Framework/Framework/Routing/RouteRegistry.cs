using System.Reflection;
using MiniHttpServer.Framework.Framework.Attributes;

namespace MiniHttpServer.Framework.Framework.Routing;

public static class RouteRegistry
{
    public static readonly Dictionary<string, RouteDescriptor> RouteDescriptors = new();

    public static void Register()
    {
        var assembly = Assembly.GetEntryAssembly() ?? throw new InvalidOperationException(
            "Не удалось определить сборку запуска приложения.");

        var httpControllers = assembly
            .GetTypes()
            .Where(t => Attribute.IsDefined(t, typeof(HttpControllerAttribute)));

        foreach (var controller in httpControllers)
        {
            var atrController = controller.GetCustomAttributes()
                .FirstOrDefault(a => a is HttpControllerAttribute);

            var atrControllerValue = atrController?
                .GetType()
                .GetProperty("Route")?
                .GetValue(atrController);

            var methods = controller
                .GetMethods()
                .Where(m => m.GetCustomAttributes()
                    .Any(a => a is HttpMethodAttribute))
                .ToArray();


            foreach (var method in methods)
            {
                var atrMethod = method.GetCustomAttributes(true)
                    .FirstOrDefault(a => a is HttpMethodAttribute);

                var atrMethodValue = atrMethod?
                    .GetType()
                    .GetProperty("Route")?
                    .GetValue(atrMethod);


                var atrMethodName = atrMethod?.GetType()
                    .Name
                    .Replace("Attribute", "")
                    .ToUpper();

                var controllerPath = atrControllerValue?.ToString() ?? string.Empty;
                var methodPath = atrMethodValue?.ToString() ?? string.Empty;

                var fullPath = RouteHelper.NormalizePath(
                    $"{controllerPath}/{methodPath}");

                var resultRoute = $"{atrMethodName}|{fullPath}";

                RouteDescriptors[resultRoute] = new RouteDescriptor(controller, method);

                RouteDescriptors[resultRoute] = new RouteDescriptor(controller, method);
            }
        }
    }
}