namespace MiniHttpServer.Framework.Framework.Storages;

public class AppStorage
{
    private readonly List<object> _services = [];

    public void Add<T>(T service) where T : class
    {
        _services.Add(service);
    }

    public object? Get(Type type)
        => _services.FirstOrDefault(type.IsInstanceOfType);
}