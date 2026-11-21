using MiniHttpServer.ORM.Attributes;

namespace MiniHttpServer.Entities;

[TableName("spell_schools")]
public class SpellSchool : IReference
{
    [PrimaryKey]
    [ColumnName("id")]
    public long Id { get; set; }

    [ColumnName("name")]
    public string Name { get; set; } = null!;

    [ColumnName("slug")]
    public string? Slug { get; set; }
}
