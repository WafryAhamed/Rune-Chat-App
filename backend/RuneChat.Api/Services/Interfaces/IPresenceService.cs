namespace RuneChat.Api.Services.Interfaces;

public interface IPresenceService
{
    bool Connect(Guid userId, string connectionId);
    bool Disconnect(Guid userId, string connectionId);
    bool IsOnline(Guid userId);
    IReadOnlyCollection<Guid> GetOnlineUsers();
    IReadOnlyCollection<string> GetConnections(Guid userId);
}
