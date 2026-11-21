using MiniHttpServer.ORM.Attributes;

namespace MiniHttpServer.Entities;

[TableName("card_spell_schools")]
public class CardSpellSchool
{
    [PrimaryKey]
    [ColumnName("card_id")]
    public long CardId { get; set; }

    [PrimaryKey]
    [ColumnName("spell_school_id")]
    public long SpellSchoolId { get; set; }
}