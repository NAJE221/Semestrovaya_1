using System.Reflection;
using MiniHttpServer.ORM.Enums;

namespace MiniHttpServer.ORM.Abstractions;

/// <summary>
///     Определяет контракт для выполнения базовых
///     CRUD-операций с реляционной базой данных.
/// </summary>
/// <remarks>
///     Поддерживает получение, добавление, изменение
///     и удаление записей с преобразованием между
///     строками таблиц и объектами .NET.
/// </remarks>
public interface IOrmContext
{
    /// <summary>
    ///     Асинхронно получает все записи указанной таблицы.
    /// </summary>
    /// <typeparam name="T">
    ///     Тип модели, в которую преобразуются записи.
    /// </typeparam>
    /// <param name="cancellationToken">
    ///     Токен отмены операции.
    /// </param>
    /// <returns>
    ///     Коллекция объектов типа <typeparamref name="T" />.
    ///     Если таблица пуста, возвращается пустая коллекция.
    /// </returns>
    Task<List<T>> GetAllAsync<T>(
        CancellationToken cancellationToken = default)
        where T : class, new();

    /// <summary>
    ///     Асинхронно добавляет запись.
    /// </summary>
    /// <typeparam name="T">
    ///     Тип добавляемой модели.
    /// </typeparam>
    /// <param name="entity">
    ///     Объект, содержащий значения новой записи.
    /// </param>
    /// <param name="cancellationToken">
    ///     Токен отмены операции.
    /// </param>
    /// <returns>
    ///     Количество добавленных записей.
    /// </returns>
    Task<int> InsertAsync<T>(
        T entity,
        CancellationToken cancellationToken = default)
        where T : class;

    public IAsyncEnumerable<T> GetAllStreamAsync<T>(
        CancellationToken cancellationToken = default)
        where T : class, new();

    /// <summary>
    ///     Асинхронно изменяет существующую запись.
    /// </summary>
    /// <typeparam name="T">
    ///     Тип модели с обновлёнными значениями.
    /// </typeparam>
    /// <param name="entity">
    ///     Объект с новыми значениями полей.
    /// </param>
    /// <param name="cancellationToken">
    ///     Токен отмены операции.
    /// </param>
    /// <returns>
    ///     Количество изменённых записей.
    /// </returns>
    Task<int> UpdateAsync<T>(
        T entity,
        CancellationToken cancellationToken = default)
        where T : class;

    /// <summary>
    ///     Асинхронно удаляет запись по первичному ключу.
    /// </summary>
    /// <param name="id">
    ///     Значение первичного ключа.
    /// </param>
    /// <param name="cancellationToken">
    ///     Токен отмены операции.
    /// </param>
    /// <returns>
    ///     Количество удалённых записей.
    /// </returns>
    Task<int> DeleteAsync<T>(
        object[] id,
        CancellationToken cancellationToken = default)
        where T : class;

    Task<T?> GetByIdAsync<T>(
        object[] id,
        CancellationToken cancellationToken = default)
        where T : class, new();

    public IAsyncEnumerable<T> GetAllByColumnsAsync<T>(
        PropertyInfo?[] properties,
        object[] values,
        PropertyInfo? sortProperty = null,
        SortDirection direction = SortDirection.Asc,
        CancellationToken cancellationToken = default)
        where T : class, new();

    public IAsyncEnumerable<T> GetAllByIntermediateTableAsync<T>(
        Type intermediateEntityType,
        PropertyInfo sourceProperty,
        PropertyInfo targetProperty,
        object value,
        CancellationToken cancellationToken = default)
        where T : class, new();
}