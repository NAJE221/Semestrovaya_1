using System.Reflection;
using MiniHttpServer.ORM.Attributes;

namespace MiniHttpServer.ORM;

public static class ReflectionHelper
{
    internal static PropertyInfo[] GetPropertyPrimaryKey(Type type) =>
        type.GetProperties()
            .Where(p => p.GetCustomAttribute<PrimaryKeyAttribute>() != null)
            .ToArray();

    internal static PropertyInfo[] GetWritablePropertiesWithoutId(Type type) =>
        GetWritableProperties(type)
            .Where(p => p.GetCustomAttribute<PrimaryKeyAttribute>() == null)
            .ToArray();
    
    internal static IEnumerable<PropertyInfo> GetWritableProperties(Type type)
    {
        return type.GetProperties(BindingFlags.Public | BindingFlags.Instance)
            .Where(p => p is { CanWrite: true, SetMethod.IsPublic: true });
    }
    
    internal static IEnumerable<string> GetColumnNames(PropertyInfo[] properties)
    {
        return properties.Select(p => 
            p.GetCustomAttribute<ColumnNameAttribute>()?.ColumnName 
            ?? p.Name.ToLowerInvariant());
    }

    // Нужно ли открвать доступ к этому методу? 
    public static string GetColumnName(PropertyInfo property)
    {
        return property.GetCustomAttribute<ColumnNameAttribute>()?.ColumnName
            ?? property.Name.ToLowerInvariant();
    }

    internal static string GetTableName<T>()
    {
        var tableNameAttribute = typeof(T).GetCustomAttribute<TableNameAttribute>();
        
        return tableNameAttribute?.TableName ?? typeof(T).Name.ToLower();
    }
    
    internal static void CheckProperty<T>(PropertyInfo property)
    {
        if (property.DeclaringType != typeof(T))
            throw new ArgumentException(
                $"Свойство {property.Name} не принадлежит типу {typeof(T).Name}.");
    }
}