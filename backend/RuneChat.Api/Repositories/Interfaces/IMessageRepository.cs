using RuneChat.Api.Models;

namespace RuneChat.Api.Repositories.Interfaces;

public interface IMessageRepository
{
    Task AddAsync(Message message, CancellationToken cancellationToken = default);
    Task<List<Message>> GetMessagesAsync(Guid conversationId, int page, int pageSize, CancellationToken cancellationToken = default);
    Task<Message?> GetByIdAsync(Guid messageId, CancellationToken cancellationToken = default);
    Task<int> CountUnreadAsync(Guid conversationId, Guid userId, CancellationToken cancellationToken = default);
    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}
