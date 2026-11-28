using System.Reflection;
using MiniHttpServer.Abstraction;
using MiniHttpServer.Domain.Entities;
using MiniHttpServer.Domain.Entities.Relations;
using MiniHttpServer.ORM.Abstractions;
using MiniHttpServer.ORM.Enums;

namespace MiniHttpServer.Repositories;

public class CardRepository(IOrmContext ormContext) : ICardRepository
{
    public async IAsyncEnumerable<CardEntity> GetCardsByColumnsAsync(
        PropertyInfo[] property,
        object?[] value,
        PropertyInfo? sortProperty = null,
        SortDirection direction = SortDirection.Asc)
    {
        await foreach (var card in ormContext.GetAllByColumnsAsync<CardEntity>(
                           property, value, sortProperty, direction))
            yield return card;
    }

    public async IAsyncEnumerable<CardClassEntity> GetAllCardClassByCardIdAsync(
        PropertyInfo[] property,
        object?[] value)
    {
        await foreach (var card in ormContext.GetAllByColumnsAsync<CardClassEntity>(property, value)) yield return card;
    }

    public async Task<long?> GetEntityIdBySlugAsync<T>(
        string slug)
        where T : SlugEntity, new()
    {
        var property = typeof(T).GetProperty(nameof(SlugEntity.Slug));
        
        

        await foreach (var filter in ormContext.GetAllByColumnsAsync<T>([property], [slug]))
            return filter.Id;
        
        return null;
    }

    public async Task<List<ClassEntity>> GetAllClassesAsync()
    {
        return await ormContext.GetAllAsync<ClassEntity>();
    }

    public async Task<T?> GetEntityBySlugAsync<T>(string slug) where T : SlugEntity, new()
    {
        var property = typeof(T).GetProperty(nameof(SlugEntity.Slug));
        await foreach (var card in ormContext.GetAllByColumnsAsync<T>([property], [slug])) return card;
        return null;
    }


    public IAsyncEnumerable<CardEntity> GetAllCardsByRelationAsync(
        Type intermediateEntityType,
        PropertyInfo sourceProperty,
        PropertyInfo targetProperty,
        object value)
    {
        return ormContext.GetAllByIntermediateTableAsync<CardEntity>(
            intermediateEntityType, sourceProperty, targetProperty, value);
    }

    public IAsyncEnumerable<CardSetEntity> GetSetsByStandardAsync(bool isStandard)
    {
        return ormContext.GetAllByColumnsAsync<CardSetEntity>(
            [typeof(CardSetEntity).GetProperty(nameof(CardSetEntity.IsStandard))],
            [isStandard]);
    }

    public IAsyncEnumerable<CardEntity> GetSetsByNameAsync(string name)
    {
        return ormContext.GetAllByColumnsAsync<CardEntity>([typeof(CardEntity).GetProperty(nameof(CardSetEntity.Name))],
            [name]);
    }
    
    public Task<T?> GetByIdAsync<T>(long id) where T : class, new()
        => ormContext.GetByIdAsync<T>([id]);

    public async Task<List<T>> GetAllByPropertyAsync<T>(string property, object value) where T : class, new()
    {
        var result = new List<T>();
        await foreach (var e in ormContext.GetAllByColumnsAsync<T>(
                           [typeof(T).GetProperty(property)], [value]))
            result.Add(e);
        return result;
    }
}