using MiniHttpServer.ORM.Attributes;

namespace MiniHttpServer.Entities;

[TableName("card_sets")]
public class CardSet : IReference
{
    [PrimaryKey]
    [ColumnName("id")]
    public long Id { get; set; }

    [ColumnName("name")]
    public string Name { get; set; } = null!;

    [ColumnName("slug")]
    public string? Slug { get; set; }
}
