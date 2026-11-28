using MiniHttpServer.Domain.Attributes;
using MiniHttpServer.ORM.Attributes;
using MiniHttpServer.ORM.Enums;

namespace MiniHttpServer.Domain.Entities.Relations;

[TableName("card_keywords")]
public class CardKeywordEntity
{
    [ColumnName("card_id")] public long CardId { get; set; }

    [ColumnName("keyword_id")]
    [CardFilter("keyword", CardFilterType.Relation, typeof(KeywordEntity))]
    public long KeywordId { get; set; }

    [ColumnName("source")] 
    public string Source { get; set; } = null!;
}