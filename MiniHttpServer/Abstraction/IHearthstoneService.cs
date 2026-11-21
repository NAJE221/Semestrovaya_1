using System.Net;

namespace MiniHttpServer.Abstraction;

public interface IHearthstoneService
{
    public Task GetFilteredCardsAsync(
        IReadOnlyDictionary<string, string> form,
        HttpListenerContext context);
    public Task GetHomePageAsync(HttpListenerContext context);

    public Task GetCardModalAsync(HttpListenerContext context);
}