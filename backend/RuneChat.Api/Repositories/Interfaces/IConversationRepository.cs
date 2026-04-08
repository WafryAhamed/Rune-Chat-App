using RuneChat.Api.Models;

namespace RuneChat.Api.Repositories.Interfaces;

public interface IConversationRepository
{
    Task<Conversation?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<Conversation?> GetByIdWithParticipantsAsync(Guid id, CancellationToken cancellationToken = default);
    Task<Conversation?> GetPrivateConversationAsync(Guid userId, Guid targetUserId, CancellationToken cancellationToken = default);
    Task<List<Conversation>> GetUserConversationsAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<int> GetMessageCountAsync(Guid conversationId, CancellationToken cancellationToken = default);
    Task AddAsync(Conversation conversation, CancellationToken cancellationToken = default);
    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}
