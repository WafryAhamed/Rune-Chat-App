using RuneChat.Api.DTOs.Chat;

namespace RuneChat.Api.Services.Interfaces;

public interface IChatService
{
    Task<ConversationSummaryDto?> CreateOrGetPrivateConversationAsync(Guid userId, Guid targetUserId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<ConversationSummaryDto>> GetConversationsAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<MessageDto>> GetMessagesAsync(Guid userId, Guid conversationId, int page, int pageSize, CancellationToken cancellationToken = default);
    Task<MessageDto?> SendMessageAsync(Guid userId, SendMessageRequest request, CancellationToken cancellationToken = default);
    Task<MessageSeenEventDto?> MarkSeenAsync(Guid userId, Guid messageId, CancellationToken cancellationToken = default);
    Task<bool> CanAccessConversationAsync(Guid userId, Guid conversationId, CancellationToken cancellationToken = default);
    Task<ChatInfoDto?> GetChatInfoAsync(Guid userId, Guid conversationId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Guid>> GetConversationParticipantIdsAsync(Guid conversationId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<MessageDto>> SearchMessagesAsync(Guid userId, string? query, CancellationToken cancellationToken = default);
}
