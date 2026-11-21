using MiniHttpServer.ORM.Attributes;

namespace MiniHttpServer.Entities;

[TableName("card_tribes")]
public class CardTribe
{
    [PrimaryKey]
    [ColumnName("card_id")]
    public long CardId { get; set; }

    [PrimaryKey]
    [ColumnName("tribe_id")]
    public long TribeId { get; set; }
}