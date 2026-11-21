namespace MiniHttpServer.Framework.Framework.Routing;

internal static class RouteHelper
{
    public static string NormalizePath(string? path)
    {
        if (string.IsNullOrWhiteSpace(path))
            return string.Empty;

        return string.Join(
            "/",
            path.Split('/', StringSplitOptions.RemoveEmptyEntries)
        );
    }
}