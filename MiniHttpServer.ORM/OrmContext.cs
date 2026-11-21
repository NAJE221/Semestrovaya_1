using System.Data.Common;
using System.Globalization;
using System.Reflection;
using MiniHttpServer.ORM.Abstractions;
using MiniHttpServer.ORM.Mappers;
using System.Runtime.CompilerServices;

namespace MiniHttpServer.ORM;

public class OrmContext(IDbDriver dbDriver) : IOrmContext
{
    private readonly IDbDriver _dbDriver = dbDriver
                                           ?? throw new ArgumentNullException(nameof(dbDriver),
                                               "Не обнаружено драйвера");

    private readonly ISqlBuilder _sqlBuilder = dbDriver.CreateSqlBuilder()
                                               ?? throw new ArgumentNullException(nameof(_sqlBuilder),
                                                   "Не обнаружено билдера");
    
    /// <inheritdoc />
    public async IAsyncEnumerable<T> GetAllStreamAsync<T>(
        [EnumeratorCancellation] CancellationToken cancellationToken = default)
        where T : class, new()
    {
        var tableName = ReflectionHelper.GetTableName<T>();

        await using var connection = await CreateConnectionAsync(cancellationToken);

        var query = _sqlBuilder.BuildSelect(tableName);
        await using var command = _dbDriver.CreateCommand(query, connection);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            yield return Mapper.MapToEntity<T>(reader);
        }
    }

    public async Task<List<T>> GetAllAsync<T>(
        CancellationToken cancellationToken = default)
        where T : class, new()
    {
        var tableName = ReflectionHelper.GetTableName<T>();
        var result = new List<T>();

        await using var connection = await CreateConnectionAsync(cancellationToken);

        var query = _sqlBuilder.BuildSelect(tableName);
        await using var command = _dbDriver.CreateCommand(query, connection);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            result.Add(Mapper.MapToEntity<T>(reader));
        }

        return result;
    }

    /// <inheritdoc />
    public async Task<int> InsertAsync<T>(
        T entity,
        CancellationToken cancellationToken = default) where T : class
    {
        ArgumentNullException.ThrowIfNull(entity);

        var tableName = ReflectionHelper.GetTableName<T>();

        await using var connection = await CreateConnectionAsync(cancellationToken);

        var query = _sqlBuilder.BuildInsert(tableName, entity);

        await using var command = _dbDriver.CreateCommand(query, connection);

        var parameters = Mapper.MapToParameters(entity, _dbDriver);

        foreach (var parameter in parameters)
        {
            command.Parameters.Add(parameter);
        }

        return await command.ExecuteNonQueryAsync(cancellationToken);
    }

    /// <inheritdoc />
    public async Task<int> UpdateAsync<T>(
        T entity,
        CancellationToken cancellationToken = default) where T : class
    {
        ArgumentNullException.ThrowIfNull(entity);

        var tableName = ReflectionHelper.GetTableName<T>();

        await using var connection = await CreateConnectionAsync(cancellationToken);

        var query = _sqlBuilder.BuildUpdate(tableName, entity);
        await using var command = _dbDriver.CreateCommand(query, connection);

        var properties = ReflectionHelper.GetWritablePropertiesWithoutId(typeof(T));
        var pkProperties = ReflectionHelper.GetPropertyPrimaryKey(typeof(T));

        var i = 0;
        foreach (var p in properties.Concat(pkProperties))
        {
            command.Parameters.Add(
                _dbDriver.CreateParameter($"@p{i++}", p.GetValue(entity)));
        }

        return await command.ExecuteNonQueryAsync(cancellationToken);
    }

    /// <inheritdoc />
    public async Task<int> DeleteAsync<T>(
        object[] id,
        CancellationToken cancellationToken = default) where T : class
    {
        CheckKey<T>(id);

        var tableName = ReflectionHelper.GetTableName<T>();

        var connection = await CreateConnectionAsync(cancellationToken);
        
        var query = _sqlBuilder.BuildDelete<T>(tableName);
        await using var command = _dbDriver.CreateCommand(query, connection);

        for (var i = 0; i < id.Length; i++)
            command.Parameters.Add(_dbDriver.CreateParameter($"@p{i}", id[i]));

        return await command.ExecuteNonQueryAsync(cancellationToken);
    }

    public async Task<T?> GetByIdAsync<T>(
        object[] id,
        CancellationToken cancellationToken = default) where T : class, new()
    {
        CheckKey<T>(id);

        var tableName = ReflectionHelper.GetTableName<T>();

        await using var connection = await CreateConnectionAsync(cancellationToken);

        var query = _sqlBuilder.BuildSelectById<T>(tableName);

        await using var command = _dbDriver.CreateCommand(query, connection);

        for (var i = 0; i < id.Length; i++)
            command.Parameters.Add(_dbDriver.CreateParameter($"@p{i}", id[i]));

        await using var reader = await command
            .ExecuteReaderAsync(cancellationToken);

        if (await reader.ReadAsync(cancellationToken))
            return Mapper.MapToEntity<T>(reader);

        return null;
    }

    public async IAsyncEnumerable<T> GetAllByColumnsAsync<T>(
    PropertyInfo[] properties,
    object[] values,
    [EnumeratorCancellation] CancellationToken cancellationToken = default)
    where T : class, new()
    {
        ArgumentNullException.ThrowIfNull(properties);
        ArgumentNullException.ThrowIfNull(values);

        if (properties.Length == 0)
            throw new ArgumentException("Не переданы свойства.");

        if (properties.Length != values.Length)
            throw new ArgumentException("Количество свойств и значений не совпадает.");

        for (var i = 0; i < properties.Length; i++)
        {
            ArgumentNullException.ThrowIfNull(properties[i]);
            ArgumentNullException.ThrowIfNull(values[i]);

            if (values[i] is object[] { Length: 0 })
                throw new ArgumentException($"Пустой список значений для {properties[i].Name}.");

            ReflectionHelper.CheckProperty<T>(properties[i]);
        }

        var tableName = ReflectionHelper.GetTableName<T>();

        await using var connection =
            await CreateConnectionAsync(cancellationToken);

        var query = _sqlBuilder.BuildGetAllByColumns(tableName, properties, values);

        await using var command =
            _dbDriver.CreateCommand(query, connection);

        var arguments = properties
            .SelectMany((property, i) => (values[i] is object[] many ? many : new[] { values[i] })
                .Select(value => ConvertValue(property, value)))
            .ToArray();

        for (var i = 0; i < arguments.Length; i++)
        {
            command.Parameters.Add(
                _dbDriver.CreateParameter($"@p{i}", arguments[i]));
        }

        await using var reader =
            await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            yield return Mapper.MapToEntity<T>(reader);
        }
    }

    private static object ConvertValue(PropertyInfo property, object value)
    {
        var type = Nullable.GetUnderlyingType(property.PropertyType) ?? property.PropertyType;
        return Convert.ChangeType(value, type, CultureInfo.InvariantCulture);
    }

    private static void CheckKey<T>(object[] id)
    {
        ArgumentNullException.ThrowIfNull(id);
        var count = ReflectionHelper.GetPropertyPrimaryKey(typeof(T)).Length;
        if (id.Length != count)
            throw new ArgumentException(
                $"Ожидалось значений ключа: {count}, получено: {id.Length}.");
    }
    
    private async Task<DbConnection> CreateConnectionAsync(
        CancellationToken cancellationToken)
    {
        var connection = _dbDriver.CreateConnection();

        try
        {
            await connection.OpenAsync(cancellationToken);
            return connection;
        }
        catch(Exception ex)
        {
            await connection.DisposeAsync();
            
            throw new Exception($"Не удалось открыть соединение с бд. {ex.Message}");
        }
    }
}