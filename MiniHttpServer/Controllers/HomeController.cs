using System.Net;
using MiniHttpServer.Abstraction;
using MiniHttpServer.Constants;
using MiniHttpServer.Framework.Framework.Abstractions;
using MiniHttpServer.Framework.Framework.Attributes;
using MiniHttpServer.Framework.Framework.Controllers;
using MiniHttpServer.Framework.Framework.Services;

namespace MiniHttpServer.Controllers;

[HttpController("hearthstone")]
public class HomeController(
    HttpListenerContext context,
    IResourceService resourceService,
    ICardFilterService cardFilterService,
    ICardModalService cardModalService) : BaseController(context, resourceService)
{
    [Get("")]
    public async Task GetFirstPage()
    {
        var homePagePath = Path.Combine(StaticPaths.Pages, "home.html");
        await File(homePagePath);
    }

    [Post("cards")]
    public async Task GetCards(IReadOnlyDictionary<string, string> form)
    {
        var filteredCards = cardFilterService.GetFilteredCardsAsync(form);
         
        form.TryGetValue("group_by_class", out var groupByClass);

        var cards = cardFilterService.GetCardsAsync(
            filteredCards,
            groupByClass == "true");

        
        
        await HttpResponseService.ExecuteStreamAsync<string>(Context, async () =>
        {
            await Html(await cardFilterService.RenderCountCards(filteredCards));
            await foreach (var cardsString in cardFilterService.RenderCardsAsync(cards))
                await Html(cardsString);
        });
    }

    [Get("card")]
    public async Task GetCardModal()
    {
        var query = Context.Request.QueryString;

        var modal = await cardModalService.GetModal(query);
        await Html(modal);
    }
}