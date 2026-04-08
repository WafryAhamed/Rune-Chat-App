using System.Collections.Concurrent;
using RuneChat.Api.Services.Interfaces;

namespace RuneChat.Api.Services.Implementations;

public sealed class PresenceService : IPresenceService
{
    private readonly ConcurrentDictionary<Guid, HashSet<string>> _connections = new();

    public bool Connect(Guid userId, string connectionId)
    {
        var wasOnline = _connections.ContainsKey(userId);
        var set = _connections.GetOrAdd(userId, _ => []);

        lock (set)
        {
            set.Add(connectionId);
        }

        return !wasOnline;
    }

    public bool Disconnect(Guid userId, string connectionId)
    {
        if (!_connections.TryGetValue(userId, out var set))
        {
            return false;
        }

        lock (set)
        {
            set.Remove(connectionId);
            if (set.Count == 0)
            {
                _connections.TryRemove(userId, out _);
                return true;
            }
        }

        return false;
    }

    public bool IsOnline(Guid userId)
    {
        return _connections.TryGetValue(userId, out var set) && set.Count > 0;
    }

    public IReadOnlyCollection<Guid> GetOnlineUsers()
    {
        return _connections.Keys.ToList();
    }

    public IReadOnlyCollection<string> GetConnections(Guid userId)
    {
        if (!_connections.TryGetValue(userId, out var set))
        {
            return [];
        }

        lock (set)
        {
            return set.ToList();
        }
    }
}
