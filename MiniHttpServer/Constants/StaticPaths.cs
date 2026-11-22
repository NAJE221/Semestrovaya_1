namespace MiniHttpServer.Constants;

internal static class StaticPaths
{
    private static readonly string Root = Directory.GetCurrentDirectory();

    public static readonly string Pages = Path.Combine(Root, "static", "pages");
    public static readonly string Templates = Path.Combine(Root, "static", "templates");
}