using System.Collections.Concurrent;
using System.Net;
using System.Reflection;
using MiniHttpServer.Abstraction;
using MiniHttpServer.Constants;
using MiniHttpServer.Entities;
using MiniHttpServer.Framework.Framework.Abstractions;
using MiniHttpServer.Framework.Framework.Services;
using MiniHttpServer.HtmlTemplating.Abstractions;
using MiniHttpServer.ORM.Abstractions;

namespace MiniHttpServer.Services;

public class HearthstoneService(
    IHearthstoneRepository hearthstoneRepository,
    IOrmContext ormContext,
    IHtmlTemplateRenderer renderer,
    IResourceService resourceService) : IHearthstoneService
{
    private static readonly ConcurrentDictionary<string, long[]> SlugCache = new();

    private static readonly PropertyInfo ClassIdProperty = typeof(Card).GetProperty(nameof(Card.ClassId))!;

    private static readonly (string Key, PropertyInfo Property)[] ColumnFilters =
    [
        ("set", typeof(Card).GetProperty(nameof(Card.CardSetId))!),
        ("rarity", typeof(Card).GetProperty(nameof(Card.RarityId))!),
        ("card_type", typeof(Card).GetProperty(nameof(Card.CardTypeId))!)
    ];
    
    
    private sealed record CardFilter(
        IReadOnlyList<(PropertyInfo Property, object[] Ids)> Columns,
        Func<Card, bool> Matches,
        string? Sort);

    public async Task GetFilteredCardsAsync(
        IReadOnlyDictionary<string, string> form,
        HttpListenerContext context)
    {
        var pathTemplateCard = Path.Combine(StaticPaths.Templates, "grid-cards-template.txt");
        var pathTemplateCountCards = Path.Combine(StaticPaths.Templates, "count-results-template.txt");

        var classId = form.GetValueOrDefault("class");

        var classes = (await hearthstoneRepository.GetAllClassAsync())
            .Where(cls => classId is null || cls.Id.ToString() == classId)
            .ToList();

        var groupByClass = !form.TryGetValue("group_by_class", out var groupValue)
                           || !bool.TryParse(groupValue, out var parsed)
                           || parsed;

        var filter = await BuildFilterAsync(form);

        await StreamAsync(context, async () =>
        {
            var count = 0;

            if (filter is not null && classes.Count > 0)
            {
                if (groupByClass)
                {
                    foreach (var cls in classes)
                    {
                        count += await RenderClassCardsAsync(
                            cls, filter, pathTemplateCard, context);
                    }
                }
                else
                {
                    count = await RenderAllCardsAsync(
                        classes, filter, pathTemplateCard, context);
                }
            }

            var html = renderer.RenderFromFile(pathTemplateCountCards, count);
            await FileService.StringPush(html, context);
        });
    }
    
    private async Task<int> RenderAllCardsAsync(
        IReadOnlyList<Class> classes,
        CardFilter filter,
        string pathTemplateCard,
        HttpListenerContext context)
    {
        var properties = new List<PropertyInfo> { ClassIdProperty };

        var values = new List<object>
        {
            classes.Select(cls => cls.Id).Cast<object>().ToArray()
        };

        foreach (var (property, ids) in filter.Columns)
        {
            properties.Add(property);
            values.Add(ids);
        }

        var matched = new List<Card>();

        await foreach (var card in hearthstoneRepository
                           .GetAllCardsByColumnsAsync(
                               properties.ToArray(),
                               values.ToArray()))
        {
            if (filter.Matches(card))
                matched.Add(card);
        }

        if (matched.Count == 0)
            return 0;

        var cards = ApplySort(matched, filter.Sort).ToList();

        var generalClass = new
        {
            Name = "Все карты",
            OrnamentSvgPath = "general.svg"
        };

        var model = new
        {
            Class = generalClass,
            Cards = cards,
            ContainerClass = "general"
        };

        var html = renderer.RenderFromFile(pathTemplateCard, model);

        await FileService.StringPush(html, context);

        return cards.Count;
    }

    private async Task<CardFilter?> BuildFilterAsync(IReadOnlyDictionary<string, string> form)
    {
        var columns = new List<(PropertyInfo, object[])>();

        foreach (var (key, property) in ColumnFilters)
        {
            if (!form.TryGetValue(key, out var raw)) continue;

            var ids = await ResolveAsync(key, Split(raw));
            if (ids is null) continue;
            if (ids.Length == 0) return null;

            columns.Add((property, ids.Cast<object>().ToArray()));
        }

        HashSet<long>? cardIds = null;

        var links = new (string Key, Func<long[], Task<HashSet<long>>> Load)[]
        {
            ("minion_type", ids => LinkedCardIdsAsync<CardTribe>(nameof(CardTribe.TribeId), l => l.CardId, ids)),
            ("spell_school", ids => LinkedCardIdsAsync<CardSpellSchool>(nameof(CardSpellSchool.SpellSchoolId), l => l.CardId, ids)),
            ("keyword", ids => LinkedCardIdsAsync<CardKeyword>(nameof(CardKeyword.KeywordId), l => l.CardId, ids)),
            ("faction", ids => LinkedCardIdsAsync<CardFaction>(nameof(CardFaction.FactionId), l => l.CardId, ids))
        };

        foreach (var (key, load) in links)
        {
            if (!form.TryGetValue(key, out var raw)) continue;

            var ids = await ResolveAsync(key, Split(raw));
            if (ids is null) continue;
            if (ids.Length == 0) return null;

            var found = await load(ids);
            if (found.Count == 0) return null;

            if (cardIds is null) cardIds = found;
            else cardIds.IntersectWith(found);

            if (cardIds.Count == 0) return null;
        }

        return new CardFilter(columns, BuildPredicate(cardIds, form), form.GetValueOrDefault("sort"));
    }

    private async Task<long[]?> ResolveAsync(string key, string[] slugs) => key switch
    {
        "set" => slugs.Contains("wild") ? null : await SetIdsAsync(slugs),
        "rarity" => await IdsBySlugAsync<Rarity>(slugs),
        "card_type" => await IdsBySlugAsync<CardType>(slugs),
        "minion_type" => await IdsBySlugAsync<Tribe>(slugs),
        "spell_school" => await IdsBySlugAsync<SpellSchool>(slugs),
        "keyword" => await IdsBySlugAsync<Keyword>(slugs),
        "faction" => await IdsBySlugAsync<Faction>(slugs),
        _ => null
    };

    private async Task<long[]> SetIdsAsync(string[] slugs)
    {
        var ids = new HashSet<long>(await IdsBySlugAsync<CardSet>(slugs));

        var groupIds = await IdsBySlugAsync<CardSetGroup>(slugs);
        if (groupIds.Length > 0)
        {
            var key = $"memberships:{string.Join(',', groupIds.Order())}";
            if (!SlugCache.TryGetValue(key, out var setIds))
            {
                var list = new List<long>();
                await foreach (var membership in ormContext.GetAllByColumnsAsync<CardSetGroupMembership>(
                                   [typeof(CardSetGroupMembership).GetProperty(nameof(CardSetGroupMembership.GroupId))!],
                                   [groupIds.Cast<object>().ToArray()]))
                {
                    list.Add(membership.CardSetId);
                }

                setIds = SlugCache[key] = list.ToArray();
            }

            ids.UnionWith(setIds);
        }

        return ids.ToArray();
    }

    private async Task<long[]> IdsBySlugAsync<T>(string[] slugs) where T : class, IReference, new()
    {
        if (slugs.Length == 0) return [];

        var key = $"{typeof(T).Name}:{string.Join(',', slugs.Order())}";
        if (SlugCache.TryGetValue(key, out var cached)) return cached;

        var slugProperty = typeof(T).GetProperty(nameof(IReference.Slug))!;
        var ids = new List<long>();

        await foreach (var entity in ormContext.GetAllByColumnsAsync<T>(
                           [slugProperty], [slugs.Cast<object>().ToArray()]))
        {
            ids.Add(entity.Id);
        }

        return SlugCache[key] = ids.ToArray();
    }

    private async Task<HashSet<long>> LinkedCardIdsAsync<TLink>(
        string idPropertyName, Func<TLink, long> cardId, long[] ids)
        where TLink : class, new()
    {
        var property = typeof(TLink).GetProperty(idPropertyName)!;
        var result = new HashSet<long>();

        await foreach (var link in ormContext.GetAllByColumnsAsync<TLink>(
                           [property], [ids.Cast<object>().ToArray()]))
        {
            result.Add(cardId(link));
        }

        return result;
    }

    private async Task<int> RenderClassCardsAsync(
        Class cls,
        CardFilter filter,
        string pathTemplateCard,
        HttpListenerContext context)
    {
        var properties = new List<PropertyInfo> { ClassIdProperty };
        var values = new List<object> { new object[] { cls.Id } };
        foreach (var (property, ids) in filter.Columns)
        {
            properties.Add(property);
            values.Add(ids);
        }

        var matched = new List<Card>();
        await foreach (var card in hearthstoneRepository
                           .GetAllCardsByColumnsAsync(properties.ToArray(), values.ToArray()))
        {
            if (filter.Matches(card))
                matched.Add(card);
        }

        if (matched.Count == 0)
            return 0;

        var cards = ApplySort(matched, filter.Sort).ToList();

        var model = new
        {
            Class = cls,
            Cards = cards,
            ContainerClass = "class-group"
        };

        var html = renderer.RenderFromFile(pathTemplateCard, model);
        
        await FileService.StringPush(html, context);

        return cards.Count;
    }

    private static Func<Card, bool> BuildPredicate(
        HashSet<long>? cardIds,
        IReadOnlyDictionary<string, string> form)
    {
        var cost = NumberMatcher(form.GetValueOrDefault("cost"));
        var attack = NumberMatcher(form.GetValueOrDefault("attack"));
        var health = NumberMatcher(form.GetValueOrDefault("health"));
        var text = TextMatcher(form.GetValueOrDefault("q"));

        return card =>
            (cardIds is null || cardIds.Contains(card.Id)) &&
            cost(card.ManaCost) &&
            attack(card.Attack) &&
            health(card.Health) &&
            text(card);
    }

    private static string[] Split(string raw) =>
        raw.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
    
    private static Func<int?, bool> NumberMatcher(string? raw)
    {
        if (string.IsNullOrWhiteSpace(raw))
            return _ => true;

        var rules = new List<(int Value, bool AtLeast)>();
        foreach (var token in Split(raw))
        {
            var atLeast = token.EndsWith('+');
            if (int.TryParse(atLeast ? token[..^1] : token, out var number))
                rules.Add((number, atLeast));
        }

        return value => value is { } v && rules.Any(r => r.AtLeast ? v >= r.Value : v == r.Value);
    }

    private static Func<Card, bool> TextMatcher(string? query)
    {
        if (string.IsNullOrWhiteSpace(query))
            return _ => true;

        var q = query.Trim();
        return card => card.Name.Contains(q, StringComparison.OrdinalIgnoreCase)
                       || (card.Description?.Contains(q, StringComparison.OrdinalIgnoreCase) ?? false)
                       || (card.FlavorText?.Contains(q, StringComparison.OrdinalIgnoreCase) ?? false);
    }

    private static IEnumerable<Card> ApplySort(IEnumerable<Card> cards, string? sort) => sort switch
    {
        "mana-desc" => cards.OrderByDescending(c => c.ManaCost).ThenBy(c => c.Name),
        "name-asc" => cards.OrderBy(c => c.Name, StringComparer.CurrentCultureIgnoreCase),
        "name-desc" => cards.OrderByDescending(c => c.Name, StringComparer.CurrentCultureIgnoreCase),
        "attack-asc" => cards.OrderBy(c => c.Attack is null).ThenBy(c => c.Attack).ThenBy(c => c.Name),
        "attack-desc" => cards.OrderBy(c => c.Attack is null).ThenByDescending(c => c.Attack).ThenBy(c => c.Name),
        "health-asc" => cards.OrderBy(c => c.Health is null).ThenBy(c => c.Health).ThenBy(c => c.Name),
        "health-desc" => cards.OrderBy(c => c.Health is null).ThenByDescending(c => c.Health).ThenBy(c => c.Name),
        "newest" => cards.OrderByDescending(c => c.Id),
        _ => cards.OrderBy(c => c.ManaCost).ThenBy(c => c.Name)
    };
    
    public async Task GetCardModalAsync(HttpListenerContext context)
    {
        var query = context.Request.QueryString;
        var slug = query["slug"];

        if (string.IsNullOrWhiteSpace(slug))
        {
            await resourceService.SendErrorPage(404, context);
            return;
        }

        Card? card = null;
        var slugProperty = typeof(Card).GetProperty(nameof(Card.Slug))!;
        await foreach (var found in ormContext.GetAllByColumnsAsync<Card>(
                           [slugProperty], [new object[] { slug }]))
        {
            card = found;
            break;
        }

        if (card is null)
        {
            await resourceService.SendErrorPage(404, context);
            return;
        }

        card.FlavorText ??= "";
        card.Description ??= "";
        card.ArtistName ??= "";
        card.ImageUrl ??= "";
        
        var clsTask = ormContext.GetByIdAsync<Class>([card.ClassId]);
        var typeTask = card.CardTypeId is { } typeId
            ? ormContext.GetByIdAsync<CardType>([typeId])
            : Task.FromResult<CardType?>(null);
        var rarityTask = card.RarityId is { } rarityId
            ? ormContext.GetByIdAsync<Rarity>([rarityId])
            : Task.FromResult<Rarity?>(null);
        var setTask = card.CardSetId is { } setId
            ? ormContext.GetByIdAsync<CardSet>([setId])
            : Task.FromResult<CardSet?>(null);

        await Task.WhenAll(clsTask, typeTask, rarityTask, setTask);

        var cls = clsTask.Result ?? new Class { Name = "—", OrnamentSvgPath = "", Slug = "" };

        var prev = query["prev"] ?? "";
        var next = query["next"] ?? "";

        var model = new
        {
            Card = card,
            CardTypeName = typeTask.Result?.Name ?? "—",
            RarityName = rarityTask.Result?.Name ?? "—",
            CardSetName = setTask.Result?.Name ?? "—",
            Class = cls,
            PrevSlug = query["prev"] ?? "",
            NextSlug = query["next"] ?? ""
        };

        var html = renderer.RenderFromFile(Path.Combine(StaticPaths.Templates, "card-modal.txt"), model);

        await StreamAsync(context, () => FileService.StringPush(html, context));
    }

    public async Task GetHomePageAsync(HttpListenerContext context)
    {
        var filePath = Path.Combine(StaticPaths.Pages, "home.html");
        await FileService.FilePush(filePath, context);
    }

    private static async Task StreamAsync(HttpListenerContext context, Func<Task> action)
    {
        FileService.StartStream(context);
        try
        {
            await action();
        }
        finally
        {
            FileService.StopStream(context);
        }
    }
}