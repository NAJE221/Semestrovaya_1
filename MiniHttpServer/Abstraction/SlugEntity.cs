namespace MiniHttpServer.Abstraction;

public abstract class SlugEntity
{
    public long? Id { get; set; }
    public string? Slug { get; set; }
}