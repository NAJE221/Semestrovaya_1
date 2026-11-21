using MiniHttpServer.ORM.Attributes;

namespace MiniHttpServer.Entities;

[TableName("card_set_group_memberships")]
public class CardSetGroupMembership
{
    [PrimaryKey]
    [ColumnName("card_set_id")]
    public long CardSetId { get; set; }

    [PrimaryKey]
    [ColumnName("group_id")]
    public long GroupId { get; set; }
}
