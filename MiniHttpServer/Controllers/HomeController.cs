using System.Net;
using MiniHttpServer.Abstraction;
using MiniHttpServer.Framework.Framework.Attributes;

namespace MiniHttpServer.Controllers;

[HttpController("hearthstone")]
public class HomeController(
    HttpListenerContext context,
    IHearthstoneService hearthstoneService)
{
    [Get("")]
    public async Task GetHomePage()
    {
        await hearthstoneService.GetHomePageAsync(context);
    }

    [Post("cards")]
    public async Task GetCards(IReadOnlyDictionary<string, string> form)
    {
        await hearthstoneService.GetFilteredCardsAsync(form, context);
    }
    
    [Get("card")]
    public async Task GetCardModal()
    {
        await hearthstoneService.GetCardModalAsync(context);
    }
}
