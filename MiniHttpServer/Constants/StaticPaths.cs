namespace MiniHttpServer.Constants;

internal static class StaticPaths
{
    private static readonly string Root = Directory.GetCurrentDirectory();

    public static readonly string Pages = Path.Combine(Root, "static", "pages");
    public static readonly string Templates = Path.Combine(Root, "static", "templates");
    public static readonly string Svg = Path.Combine(Root, "static", "svg");
    public static readonly string Css = Path.Combine(Root, "static", "css");
    public static readonly string Js = Path.Combine(Root, "static", "js");
    
}