using MiniHttpServer.ORM.Attributes;

namespace MiniHttpServer.Entities;

[TableName("card_factions")]
public class CardFaction
{
    [PrimaryKey]
    [ColumnName("card_id")]
    public long CardId { get; set; }

    [PrimaryKey]
    [ColumnName("faction_id")]
    public long FactionId { get; set; }
}