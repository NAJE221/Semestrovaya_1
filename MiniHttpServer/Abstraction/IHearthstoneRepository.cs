using System.Reflection;
using MiniHttpServer.Domain.Entities;
using MiniHttpServer.Domain.Entities.Relations;
using MiniHttpServer.ORM.Enums;

namespace MiniHttpServer.Abstraction;

public interface ICardRepository
{
    Task<T?> GetByIdAsync<T>(long id) where T : class, new();
    Task<List<T>> GetAllByPropertyAsync<T>(string property, object value) where T : class, new();
    
    public IAsyncEnumerable<CardEntity> GetCardsByColumnsAsync(
        PropertyInfo[] property,
        object?[] value,
        PropertyInfo? sortProperty = null,
        SortDirection direction = SortDirection.Asc);


    public Task<long?> GetEntityIdBySlugAsync<T>(
        string slug)
        where T : SlugEntity, new();

    public Task<List<ClassEntity>> GetAllClassesAsync();

    public IAsyncEnumerable<CardClassEntity> GetAllCardClassByCardIdAsync(
        PropertyInfo[] property,
        object?[] value);

    public Task<T?> GetEntityBySlugAsync<T>(string slug) where T : SlugEntity, new();


    IAsyncEnumerable<CardEntity> GetAllCardsByRelationAsync(
        Type intermediateEntityType,
        PropertyInfo sourceProperty,
        PropertyInfo targetProperty,
        object value);

    IAsyncEnumerable<CardSetEntity> GetSetsByStandardAsync(bool isStandard);

    public IAsyncEnumerable<CardEntity> GetSetsByNameAsync(string name);
}