using System.Net;
using MiniHttpServer.Framework.Framework.Storages;

namespace MiniHttpServer.Framework.Framework.Factories;

public static class ControllerFactory
{
    public static object Create(
        Type controllerType,
        HttpListenerContext context,
        AppStorage services)
    {
        var constructor = controllerType
            .GetConstructors()
            .Single();
        

        var parameters = constructor.GetParameters();
        var arguments = new object[parameters.Length];

        for (var i = 0; i < parameters.Length; i++)
        {
            var type = parameters[i].ParameterType;

            
            if (type == typeof(HttpListenerContext))
            {
                arguments[i] = context;
                continue;
            }

            if (type == typeof(HttpListenerRequest))
            {
                arguments[i] = context.Request;
                continue;
            }

            if (type == typeof(HttpListenerResponse))
            {
                arguments[i] = context.Response;
                continue;
            }
            
            arguments[i] = services.Get(type)
                           ?? throw new InvalidOperationException(
                               $"Сервис {type.Name} не зарегистрирован " +
                               $"(нужен для {controllerType.Name})");
        }

        return constructor.Invoke(arguments);
    }
}