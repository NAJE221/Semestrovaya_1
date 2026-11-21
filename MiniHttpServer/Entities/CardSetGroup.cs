using MiniHttpServer.ORM.Attributes;

namespace MiniHttpServer.Entities;

[TableName("card_set_groups")]
public class CardSetGroup : IReference
{
    [PrimaryKey]
    [ColumnName("id")]
    public long Id { get; set; }

    [ColumnName("name")]
    public string Name { get; set; } = null!;

    [ColumnName("slug")]
    public string? Slug { get; set; }
}
