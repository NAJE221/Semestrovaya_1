using MiniHttpServer.Abstraction;
using MiniHttpServer.Domain.Attributes;
using MiniHttpServer.ORM.Attributes;
using MiniHttpServer.ORM.Enums;

namespace MiniHttpServer.Domain.Entities;

[TableName("cards")]
public class CardEntity : SlugEntity
{
    [PrimaryKey] 
    [ColumnName("id")] 
    public long Id { get; set; }

    [ColumnName("card_code")] 
    public string CardCode { get; set; } = null!;

    [ColumnName("slug")] 
    public string Slug { get; set; } = null!;

    [ColumnName("name")] 
    [Like] 
    public string Name { get; set; } = null!;

    [ColumnName("text")] 
    public string? Text { get; set; }

    [ColumnName("flavor_text")] 
    public string? FlavorText { get; set; }

    [ColumnName("image")] 
    public string? Image { get; set; }

    [ColumnName("artist_name")]
    public string? ArtistName { get; set; }

    [ColumnName("mana_cost")]
    [CardFilter("cost", CardFilterType.Column, null)]
    public short? ManaCost { get; set; }

    [ColumnName("attack")]
    [CardFilter("attack", CardFilterType.Column, null)]
    public short? Attack { get; set; }

    [ColumnName("health")]
    [CardFilter("health", CardFilterType.Column, null)]
    public short? Health { get; set; }

    [ColumnName("durability")] public short? Durability { get; set; }

    [ColumnName("armor")] public short? Armor { get; set; }

    [ColumnName("collectible")] public bool Collectible { get; set; }

    [ColumnName("card_set_id")]
    [CardFilter("set", CardFilterType.Column, typeof(CardSetEntity))]
    public long? CardSetId { get; set; }

    [ColumnName("card_type_id")]
    [CardFilter("card_type", CardFilterType.Column, typeof(CardTypeEntity))]
    public long? CardTypeId { get; set; }

    [ColumnName("rarity_id")]
    [CardFilter("rarity", CardFilterType.Column, typeof(RarityEntity))]
    public long? RarityId { get; set; }
}