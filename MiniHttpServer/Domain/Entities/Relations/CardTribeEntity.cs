using MiniHttpServer.Domain.Attributes;
using MiniHttpServer.ORM.Attributes;
using MiniHttpServer.ORM.Enums;

namespace MiniHttpServer.Domain.Entities.Relations;

[TableName("card_tribes")]
public class CardTribeEntity
{
    [ColumnName("card_id")] public long CardId { get; set; }

    [ColumnName("tribe_id")]
    [CardFilter("minion_type", CardFilterType.Relation, typeof(TribeEntity))]
    public long TribeId { get; set; }
}