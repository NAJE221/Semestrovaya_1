using MiniHttpServer.ORM.Enums;

namespace MiniHttpServer.Domain.Attributes;

[AttributeUsage(AttributeTargets.Property)]
public class CardFilterAttribute(string key, CardFilterType type, Type? entityType) : Attribute
{
    public string Key { get; set; } = key;

    public CardFilterType Type { get; set; } = type;

    public Type? EntityType { get; set; } = entityType;
}