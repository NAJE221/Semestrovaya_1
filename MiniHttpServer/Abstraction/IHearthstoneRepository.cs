using System.Reflection;
using MiniHttpServer.Entities;

namespace MiniHttpServer.Abstraction;

public interface IHearthstoneRepository
{
    public IAsyncEnumerable<Card> GetAllCardsByColumnsAsync(
        PropertyInfo[] property,
        object[] value);
    
    public Task<List<Class>> GetAllClassAsync();
}