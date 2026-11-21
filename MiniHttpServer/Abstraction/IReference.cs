namespace MiniHttpServer.Entities;

/// <summary>Справочник со slug, по которому его находят фильтры страницы.</summary>
public interface IReference
{
    long Id { get; }
    string? Slug { get; }
}
