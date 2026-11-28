namespace MiniHttpServer.Framework.Framework.Configuration;

public class ServerSettings
{
    public string Host { get; set; } = "127.0.0.1";
    public int Port { get; set; } = 8080;

    public string Path { get; set; } = "";

    public override string ToString()
    {
        return $"Host={Host}; Port={Port}; Path={Path}";
    }
}