using MiniHttpServer.Abstraction;
using MiniHttpServer.ORM.Attributes;

namespace MiniHttpServer.Domain.Entities;

[TableName("rarities")]
public class RarityEntity : SlugEntity
{
    [PrimaryKey] [ColumnName("id")] public long Id { get; set; }

    [ColumnName("code")] public string Code { get; set; } = null!;

    [ColumnName("name")] public string Name { get; set; } = null!;

    [ColumnName("slug")] public string Slug { get; set; } = null!;

    [ColumnName("craft_cost")] public short? CraftCost { get; set; }

    [ColumnName("craft_cost_golden")] public short? CraftCostGolden { get; set; }

    [ColumnName("disenchant_dust")] public short? DisenchantDust { get; set; }

    [ColumnName("disenchant_dust_golden")] public short? DisenchantDustGolden { get; set; }

    [ColumnName("sort_order")] public short SortOrder { get; set; }
}