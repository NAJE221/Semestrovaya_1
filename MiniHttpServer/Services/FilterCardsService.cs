using System.Globalization;
using System.Reflection;
using MiniHttpServer.Abstraction;
using MiniHttpServer.Constants;
using MiniHttpServer.Domain.Attributes;
using MiniHttpServer.Domain.Entities;
using MiniHttpServer.Domain.Entities.Relations;
using MiniHttpServer.HtmlTemplating.Abstractions;
using MiniHttpServer.ORM.Enums;

namespace MiniHttpServer.Services;

public class FilterCardsService : ICardFilterService
{
    private const string GridCardsTemplate = "grid-cards-template.txt";
    private const string CountResultTemplate = "count-results-template.txt";

    private static readonly (PropertyInfo Property, SortDirection Direction)? DefaultSort =
        (typeof(CardEntity).GetProperty(nameof(CardEntity.ManaCost)), SortDirection.Desc)!;

    private static readonly Dictionary<Type, PropertyInfo> CardKeys = new()
    {
        [typeof(CardClassEntity)] = typeof(CardClassEntity)
            .GetProperty(nameof(CardClassEntity.CardId))!,
        [typeof(CardTribeEntity)] = typeof(CardTribeEntity)
            .GetProperty(nameof(CardTribeEntity.CardId))!,
        [typeof(CardSpellSchoolEntity)] = typeof(CardSpellSchoolEntity)
            .GetProperty(nameof(CardSpellSchoolEntity.CardId))!,
        [typeof(CardKeywordEntity)] = typeof(CardKeywordEntity)
            .GetProperty(nameof(CardKeywordEntity.CardId))!,
        [typeof(CardFactionEntity)] = typeof(CardFactionEntity)
            .GetProperty(nameof(CardFactionEntity.CardId))!
    };

    private readonly ICardRepository _cardRepository;
    private readonly List<ClassEntity> _classes;
    private readonly CardFilter[] _filters;
    private readonly IHtmlTemplateRenderer _renderer;


    // TODO добавить остальные связи многие ко многим
    private FilterCardsService(
        ICardRepository cardRepository,
        IHtmlTemplateRenderer renderer,
        List<ClassEntity> classes)
    {
        _cardRepository = cardRepository;
        _renderer = renderer;
        _classes = classes;

        _filters =
        [
            .. CreateFilters(typeof(CardEntity)),

            .. CreateFilters(typeof(CardClassEntity)),
            .. CreateFilters(typeof(CardTribeEntity)),
            .. CreateFilters(typeof(CardSpellSchoolEntity)),
            .. CreateFilters(typeof(CardKeywordEntity)),
            .. CreateFilters(typeof(CardFactionEntity))
        ];
    }
    
    public static async Task<ICardFilterService> Create(
        ICardRepository cardRepository,
        IHtmlTemplateRenderer renderer)
    {
        var classes = await cardRepository.GetAllClassesAsync();

        return new FilterCardsService(cardRepository, renderer, classes);
    }

    public async IAsyncEnumerable<CardEntity> GetFilteredCardsAsync(
        IReadOnlyDictionary<string, string> form)
    {
      
        
        var columns = new List<(PropertyInfo Property, object Value)>();
        var relations = new List<(PropertyInfo Property, object Value)>();

        foreach (var (key, text) in form)
        {
            // Подумать как переделать
            if (key == "set" && text is "standard" or "wild")
            {
                if (!await TryAddStandardFilterAsync(text == "standard", columns))
                    yield break;

                continue;
            }

            // тоже Подумать как переделать
            if (key == "q")
            {
                if (string.IsNullOrEmpty(text))
                    yield break;

                if (!await TryAddCardByName(text, columns))
                    yield break;

                continue;
            }

            var filter = _filters.FirstOrDefault(f => f.Key == key);

            if (filter.Key == null || string.IsNullOrWhiteSpace(text))
                continue;

            object value = text.Split(',');

            if (filter.FindId != null)
            {
                var id = await filter.FindId(text);

                if (id == null) yield break;
                value = id.Value;
            }

            var target = filter.Type == CardFilterType.Relation
                ? relations
                : columns;

            target.Add((filter.Property, value));
        }

        if (columns.Count == 0 && relations.Count == 0)
            throw new ArgumentException("Ошибка! Список фильтров пуст.");

        (PropertyInfo Property, SortDirection Direction)? parsSort = null;

        if (form.TryGetValue("sort", out var sort))
            parsSort = ParseSort(sort) ?? DefaultSort;

        List<CardEntity>? result = null;

        if (columns.Count > 0)
            result = await GetCardsByColumnsAsync(columns,
                parsSort!.Value.Property,
                parsSort.Value.Direction).ToListAsync();

        foreach (var (property, value) in relations)
        {
            var found = await GetCardsByRelationAsync(property, value).ToListAsync();

            if (result == null)
            {
                result = found;
            }
            else
            {
                var ids = found.Select(c => c.Id).ToHashSet();
                result.RemoveAll(c => !ids.Contains(c.Id));
            }
        }

        foreach (var card in result!)
            yield return card;
    }


    public async IAsyncEnumerable<object> GetCardsAsync(
        IAsyncEnumerable<CardEntity> cards,
        bool groupByClass)
    {
        if (groupByClass)
        {
            await foreach (var group in GetCardsByClassAsync(cards))
                yield return group;

            yield break;
        }

        var generalClass = await _cardRepository
            .GetEntityBySlugAsync<ClassEntity>("all_classes");


        var cardsList = await cards.ToListAsync();
        yield return new
        {
            Class = generalClass,
            Cards = cardsList,
            Count = cardsList.Count
        };
    }

    public async IAsyncEnumerable<string> RenderCardsAsync(
        IAsyncEnumerable<object> enumerable)
    {
        var templatePath = Path.Combine(StaticPaths.Templates, GridCardsTemplate);

        await foreach (var model in enumerable) 
            yield return _renderer.RenderFromFile(templatePath, model);
    }

    public async Task<string> RenderCountCards(IAsyncEnumerable<object> enumerable)
    {
        var count = await enumerable.CountAsync();
        var template = Path.Combine(StaticPaths.Templates, CountResultTemplate);

        return _renderer.RenderFromFile(template, count);
    }

    private static (PropertyInfo Property, SortDirection Direction)? ParseSort(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
            return null;

        var parts = value.Split('-');

        if (parts.Length != 2)
            return null;

        var property = parts[0] switch
        {
            "mana" => typeof(CardEntity).GetProperty(nameof(CardEntity.ManaCost)),
            "attack" => typeof(CardEntity).GetProperty(nameof(CardEntity.Attack)),
            "health" => typeof(CardEntity).GetProperty(nameof(CardEntity.Health)),
            "name" => typeof(CardEntity).GetProperty(nameof(CardEntity.Name)),
            _ => null
        };

        if (property == null)
            return null;

        var direction = parts[1] switch
        {
            "asc" => SortDirection.Asc,
            "desc" => SortDirection.Desc,
            _ => (SortDirection?)null
        };

        return direction == null
            ? null
            : (property, direction.Value);
    }

    private async IAsyncEnumerable<object> GetCardsByClassAsync(
        IAsyncEnumerable<CardEntity> cards)
    {
        var cardsByClass = new Dictionary<long, LinkedList<CardEntity>>();

        await foreach (var card in cards)
            await foreach (var cardClass in _cardRepository.GetAllCardClassByCardIdAsync(
                               [CardKeys[typeof(CardClassEntity)]],
                               [card.Id]))
            {
                if (!cardsByClass.TryGetValue(cardClass.ClassId, out var suitableCards))
                {
                    suitableCards = new LinkedList<CardEntity>();
                    cardsByClass.Add(cardClass.ClassId, suitableCards);
                }

                suitableCards.AddLast(card);
            }

        foreach (var (classId, suitableCards) in cardsByClass)
            yield return new
            {
                Class = _classes.FirstOrDefault(c => c.Id == classId),
                Cards = suitableCards,
                Count = suitableCards.Count
            };
    }


    // Вспомогательные методы 
    private async Task<bool> TryAddStandardFilterAsync(
        bool isStandard,
        List<(PropertyInfo Property, object Value)> columns)
    {
        var setIds = await _cardRepository.GetSetsByStandardAsync(isStandard)
            .Select(c => (object)c.Id).ToArrayAsync();

        if (setIds.Length == 0) return false;

        columns.Add((typeof(CardEntity).GetProperty(nameof(CardEntity.CardSetId))!,
            setIds.ToArray()));

        return true;
    }

    private async Task<bool> TryAddCardByName(string name,
        List<(PropertyInfo Property, object Value)> columns)
    {
        var cardNames = await _cardRepository.GetSetsByNameAsync(name)
            .Select(c => c.Name)
            .ToArrayAsync();


        if (cardNames.Length == 0) return false;

        columns.Add((typeof(CardEntity).GetProperty(nameof(CardEntity.Name))!,
            cardNames));

        return true;
    }


    private IAsyncEnumerable<CardEntity> GetCardsByColumnsAsync(
        List<(PropertyInfo Property, object Value)> filters, PropertyInfo sortProperty, SortDirection direction)
    {
        return _cardRepository.GetCardsByColumnsAsync(
            filters.Select(f => f.Property)
                .ToArray(),
            filters.Select(f => f.Value)
                .ToArray(),
            sortProperty,
            direction);
    }

    private IAsyncEnumerable<CardEntity> GetCardsByRelationAsync(
        PropertyInfo property, object value)
    {
        var linkType = property.DeclaringType!;

        return _cardRepository.GetAllCardsByRelationAsync(
            linkType, CardKeys[linkType], property, value);
    }

    private CardFilter[] CreateFilters(Type entityType)
    {
        return entityType
            .GetProperties()
            .Where(p => p.GetCustomAttribute<CardFilterAttribute>() != null)
            .Select(p =>
            {
                var attribute = p.GetCustomAttribute<CardFilterAttribute>()!;

                var findId = attribute.EntityType == null
                    ? null
                    : typeof(ICardRepository)
                        .GetMethod(nameof(ICardRepository.GetEntityIdBySlugAsync))!
                        .MakeGenericMethod(attribute.EntityType)
                        .CreateDelegate<Func<string, Task<long?>>>(_cardRepository);

                return new CardFilter(attribute.Key, attribute.Type, p, findId);
            })
            .ToArray();
    }

    private readonly record struct CardFilter(
        string Key,
        CardFilterType Type,
        PropertyInfo Property,
        Func<string, Task<long?>>? FindId
    );
}