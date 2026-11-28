using MiniHttpServer.Domain.Attributes;
using MiniHttpServer.ORM.Attributes;
using MiniHttpServer.ORM.Enums;

namespace MiniHttpServer.Domain.Entities.Relations;

[TableName("card_spell_schools")]
public class CardSpellSchoolEntity
{
    [ColumnName("card_id")] public long CardId { get; set; }

    [ColumnName("spell_school_id")]
    [CardFilter("spell_school", CardFilterType.Relation, typeof(SpellSchoolEntity))]
    public long SpellSchoolId { get; set; }
}