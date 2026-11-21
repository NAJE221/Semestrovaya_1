using MiniHttpServer.ORM.Attributes;

namespace MiniHttpServer.Entities;

[TableName("card_keywords")]
public class CardKeyword
{
    [PrimaryKey]
    [ColumnName("card_id")]
    public long CardId { get; set; }

    [PrimaryKey]
    [ColumnName("keyword_id")]
    public long KeywordId { get; set; }

    [ColumnName("parameter_value")]
    public string? ParameterValue { get; set; }
}