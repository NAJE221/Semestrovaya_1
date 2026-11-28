using MiniHttpServer.Domain.Entities;

namespace MiniHttpServer.Abstraction;

public interface ICardFilterService
{
    public IAsyncEnumerable<CardEntity> GetFilteredCardsAsync(
        IReadOnlyDictionary<string, string> form);

    public IAsyncEnumerable<string> RenderCardsAsync(
        IAsyncEnumerable<object> enumerable);

    public IAsyncEnumerable<object> GetCardsAsync(
        IAsyncEnumerable<CardEntity> cards, bool groupByClass);

    public Task<string> RenderCountCards(IAsyncEnumerable<object> enumerable);
}