using MiniHttpServer.Framework.Framework.Configuration;

namespace MiniHttpServer.Framework.Framework.Factories;

public static class UriFactory
{
    public static UriBuilder CreateUri(ServerSettings serverSettings)
    {
        UriBuilder uriBuilder = new()
        {
            Scheme = "http",
            Host = serverSettings.Host,
            Port = serverSettings.Port
        };

        return uriBuilder;
    }
}