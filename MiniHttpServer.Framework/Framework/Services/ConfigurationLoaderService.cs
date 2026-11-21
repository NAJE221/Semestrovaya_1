using MiniHttpServer.Framework.Framework.Options;

namespace MiniHttpServer.Framework.Framework.Services;

public static class ConfigurationLoaderService
{
    public static Task<ServerOptions> Load(string filePath , string sectionName)
    {
        return JsonConfigurationLoader.DeserializeAsync<ServerOptions>(filePath, sectionName);
    }
}