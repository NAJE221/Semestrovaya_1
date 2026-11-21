using MiniHttpServer.ORM.Attributes;

namespace MiniHttpServer.Entities;

[TableName("factions")]
public class Faction : IReference
{
    [PrimaryKey]
    [ColumnName("id")]
    public long Id { get; set; }

    [ColumnName("name")]
    public string Name { get; set; } = null!;

    [ColumnName("slug")]
    public string? Slug { get; set; }
}
