using System.Reflection;
using MiniHttpServer.Abstraction;
using MiniHttpServer.Entities;
using MiniHttpServer.ORM.Abstractions;

namespace MiniHttpServer.Repositories;

public class NpgsqlIiHearthstoneRepository(IOrmContext ormContext) : IHearthstoneRepository
{
    public async IAsyncEnumerable<Card> GetAllCardsByColumnsAsync(
        PropertyInfo[] property , 
        object[] value)
    {
        await foreach (var card in ormContext.GetAllByColumnsAsync<Card>(property , value))
        {
            yield return card;
        }
    }

    public async Task<List<Class>> GetAllClassAsync()
    {
        return await ormContext.GetAllAsync<Class>();
    }
}