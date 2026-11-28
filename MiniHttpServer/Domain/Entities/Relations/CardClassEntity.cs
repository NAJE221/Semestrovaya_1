using MiniHttpServer.Domain.Attributes;
using MiniHttpServer.ORM.Attributes;
using MiniHttpServer.ORM.Enums;

namespace MiniHttpServer.Domain.Entities.Relations;

[TableName("card_classes")]
public class CardClassEntity
{
    [ColumnName("card_id")] 
    public long CardId { get; set; }

    [ColumnName("class_id")]
    [CardFilter("class", CardFilterType.Relation, typeof(ClassEntity))]
    public long ClassId { get; set; }
}