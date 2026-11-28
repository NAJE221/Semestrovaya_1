using MiniHttpServer.Domain.Attributes;
using MiniHttpServer.ORM.Attributes;
using MiniHttpServer.ORM.Enums;

namespace MiniHttpServer.Domain.Entities.Relations;

[TableName("card_factions")]
public class CardFactionEntity
{
    [ColumnName("card_id")] public long CardId { get; set; }

    [ColumnName("faction_id")]
    [CardFilter("faction", CardFilterType.Relation, typeof(FactionEntity))]
    public long FactionId { get; set; }
}