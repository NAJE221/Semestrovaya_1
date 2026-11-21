using MiniHttpServer.ORM.Attributes;

namespace MiniHttpServer.Entities;

[TableName("cards")]
public class Card
{
    [PrimaryKey]
    [ColumnName("id")]
    public long Id { get; set; }

    [ColumnName("card_code")]
    public string CardCode { get; set; } = null!;

    [ColumnName("slug")]
    public string? Slug { get; set; }

    [ColumnName("name")]
    public string Name { get; set; } = null!;

    [ColumnName("text")]
    public string? Description { get; set; }

    [ColumnName("flavor_text")]
    public string? FlavorText { get; set; }

    [ColumnName("image")]
    public string? ImageUrl { get; set; }

    [ColumnName("image_gold")]
    public string? ImageGold { get; set; }

    [ColumnName("crop_image")]
    public string? CropImage { get; set; }

    [ColumnName("artist_name")]
    public string? ArtistName { get; set; }

    [ColumnName("mana_cost")]
    public short ManaCost { get; set; }

    [ColumnName("attack")]
    public short? Attack { get; set; }

    [ColumnName("health")]
    public short? Health { get; set; }

    [ColumnName("durability")]
    public short? Durability { get; set; }

    [ColumnName("overload")]
    public short? Overload { get; set; }

    [ColumnName("spell_damage")]
    public short? SpellDamage { get; set; }

    [ColumnName("rune_cost")]
    public string? RuneCost { get; set; }

    [ColumnName("collectible")]
    public bool IsCollectible { get; set; }

    [ColumnName("card_set_id")]
    public long? CardSetId { get; set; }

    [ColumnName("card_type_id")]
    public long? CardTypeId { get; set; }

    [ColumnName("rarity_id")]
    public long? RarityId { get; set; }

    [ColumnName("class_id")]
    public long ClassId { get; set; }
}