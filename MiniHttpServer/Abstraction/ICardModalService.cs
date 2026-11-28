using System.Collections.Specialized;

namespace MiniHttpServer.Abstraction;

public interface ICardModalService
{
    public Task<string> GetModal(NameValueCollection query);
}