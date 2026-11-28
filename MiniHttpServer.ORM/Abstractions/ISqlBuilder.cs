using System.Reflection;
using MiniHttpServer.ORM.Enums;

namespace MiniHttpServer.ORM.Abstractions;

public interface ISqlBuilder
{
    string BuildSelect(string tableName);
    string BuildSelectById<T>(string tableName) where T : class;

    public string BuildGetAllByColumns(string tableName,
        PropertyInfo?[] properties,
        object[] values);

    public string BuildGetAllByIntermediateTable(
        string tableName,
        string intermediateTableName,
        PropertyInfo primaryKeyProperty,
        PropertyInfo sourceProperty,
        PropertyInfo targetProperty);

    string BuildInsert<T>(string tableName, T entity) where T : class;
    string BuildUpdate<T>(string tableName, T entity) where T : class;
    string BuildDelete<T>(string tableName) where T : class;
    public string BuildOrderBy(PropertyInfo property, SortDirection sortDirection);
}