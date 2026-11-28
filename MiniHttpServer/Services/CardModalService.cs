using System.Collections.Specialized;
using MiniHttpServer.Abstraction;
using MiniHttpServer.Constants;
using MiniHttpServer.Domain.Entities;
using MiniHttpServer.Domain.Entities.Relations;
using MiniHttpServer.HtmlTemplating.Abstractions;

namespace MiniHttpServer.Services;

public class CardModalService(ICardRepository repository, IHtmlTemplateRenderer render) : ICardModalService
{
    private const string Template = "card-modal.txt";

    public async Task<string> GetModal(NameValueCollection query)
    {
        var slug = query["slug"];
        if (string.IsNullOrWhiteSpace(slug)) return "";

        var card = await repository.GetEntityBySlugAsync<CardEntity>(slug);
        if (card is null) return "";

        var type = card.CardTypeId is { } t ? await repository.GetByIdAsync<CardTypeEntity>(t) : null;
        var rarity = card.RarityId is { } r ? await repository.GetByIdAsync<RarityEntity>(r) : null;
        var set = card.CardSetId is { } s ? await repository.GetByIdAsync<CardSetEntity>(s) : null;

        var classNames = new List<string>();
        foreach (var rel in await repository.GetAllByPropertyAsync<CardClassEntity>(
                     nameof(CardClassEntity.CardId), card.Id))
            if (await repository.GetByIdAsync<ClassEntity>(rel.ClassId) is { } c)
                classNames.Add(c.Name);

        var keywordNames = new List<string>();
        foreach (var rel in await repository.GetAllByPropertyAsync<CardKeywordEntity>(
                     nameof(CardKeywordEntity.CardId), card.Id))
            if (rel.Source == "mechanic" &&
                await repository.GetByIdAsync<KeywordEntity>(rel.KeywordId) is { } k)
                keywordNames.Add(k.Name);

        var hasCraft = rarity?.CraftCost is not null;
        var hasDust = rarity?.DisenchantDust is not null;

        var model = new
        {
            Card = card,
            PrevSlug = query["prev"] ?? "",
            NextSlug = query["next"] ?? "",
            HasPrev = !string.IsNullOrEmpty(query["prev"]),
            HasNext = !string.IsNullOrEmpty(query["next"]),

            TypeName = type?.Name ?? "—",
            RarityName = rarity?.Name ?? "—",
            SetName = set?.Name ?? "—",
            ClassName = classNames.Count > 0 ? string.Join(", ", classNames) : "—",

            HasCraft = hasCraft,
            Craft = $"{rarity?.CraftCost} / {rarity?.CraftCostGolden} (Золотые)",
            HasDust = hasDust,
            Dust = $"{rarity?.DisenchantDust} / {rarity?.DisenchantDustGolden} (Золотые)",

            HasArtist = !string.IsNullOrWhiteSpace(card.ArtistName),
            HasKeywords = keywordNames.Count > 0,
            Keywords = string.Join(", ", keywordNames)
        };

        return render.RenderFromFile(Path.Combine(StaticPaths.Templates, Template), model);
    }
}