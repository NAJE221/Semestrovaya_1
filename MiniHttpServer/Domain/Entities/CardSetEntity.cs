using MiniHttpServer.Abstraction;
using MiniHttpServer.ORM.Attributes;

namespace MiniHttpServer.Domain.Entities;

[TableName("card_sets")]
public class CardSetEntity : SlugEntity
{
    [PrimaryKey] [ColumnName("id")] public long Id { get; set; }

    [ColumnName("source_code")] public string SourceCode { get; set; } = null!;

    [ColumnName("name")] public string Name { get; set; } = null!;

    [ColumnName("slug")] public string Slug { get; set; } = null!;

    [ColumnName("sort_order")] public short SortOrder { get; set; }

    [ColumnName("is_standard")] public bool IsStandard { get; set; }
}