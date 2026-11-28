using MiniHttpServer.Abstraction;
using MiniHttpServer.ORM.Attributes;

namespace MiniHttpServer.Domain.Entities;

[TableName("keywords")]
public class KeywordEntity : SlugEntity
{
    [PrimaryKey]
    [ColumnName("id")] 
    public long? Id { get; set; }

    [ColumnName("code")] 
    public string Code { get; set; } = null!;

    [ColumnName("name")] 
    public string Name { get; set; } = null!;

    [ColumnName("slug")] 
    public string Slug { get; set; } = null!;
}