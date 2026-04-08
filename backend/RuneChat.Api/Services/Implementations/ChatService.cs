using Microsoft.EntityFrameworkCore;
using RuneChat.Api.Data;
using RuneChat.Api.DTOs.Chat;
using RuneChat.Api.Models;
using RuneChat.Api.Repositories.Interfaces;
using RuneChat.Api.Services.Interfaces;

namespace RuneChat.Api.Services.Implementations;

public sealed class ChatService(
    IConversationRepository conversationRepository,
    IMessageRepository messageRepository,
    IUserRepository userRepository,
    IUserBlockRepository userBlockRepository,
    IPresenceService presenceService,
    AppDbContext dbContext) : IChatService
{
    public async Task<ConversationSummaryDto?> CreateOrGetPrivateConversationAsync(Guid userId, Guid targetUserId, CancellationToken cancellationToken = default)
    {
        if (userId == targetUserId)
        {
            return null;
        }

        var isBlocked = await userBlockRepository.IsEitherBlockedAsync(userId, targetUserId, cancellationToken);
        if (isBlocked)
        {
            return null;
        }

        var targetUser = await userRepository.GetByIdAsync(targetUserId, track: false, cancellationToken);
        if (targetUser is null)
        {
            return null;
        }

        var existing = await conversationRepository.GetPrivateConversationAsync(userId, targetUserId, cancellationToken);
        if (existing is not null)
        {
            return await BuildConversationSummaryAsync(existing, userId, cancellationToken);
        }

        var conversation = new Conversation
        {
            IsGroup = false,
            Participants =
            {
                new ConversationParticipant
                {
                    UserId = userId,
                    LastReadAt = DateTime.UtcNow
                },
                new ConversationParticipant
                {
                    UserId = targetUserId,
                    LastReadAt = DateTime.UtcNow
                }
            }
        };

        await conversationRepository.AddAsync(conversation, cancellationToken);
        await conversationRepository.SaveChangesAsync(cancellationToken);

        var hydrated = await conversationRepository.GetByIdWithParticipantsAsync(conversation.Id, cancellationToken);
        return hydrated is null ? null : await BuildConversationSummaryAsync(hydrated, userId, cancellationToken);
    }

    public async Task<IReadOnlyList<ConversationSummaryDto>> GetConversationsAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var conversations = await conversationRepository.GetUserConversationsAsync(userId, cancellationToken);

        var results = new List<ConversationSummaryDto>(conversations.Count);
        foreach (var conversation in conversations)
        {
            results.Add(await BuildConversationSummaryAsync(conversation, userId, cancellationToken));
        }

        return results
            .OrderByDescending(c => c.LastMessageAt ?? DateTime.MinValue)
            .ToList();
    }

    public async Task<IReadOnlyList<MessageDto>> GetMessagesAsync(Guid userId, Guid conversationId, int page, int pageSize, CancellationToken cancellationToken = default)
    {
        var canAccess = await CanAccessConversationAsync(userId, conversationId, cancellationToken);
        if (!canAccess)
        {
            return [];
        }

        var messages = await messageRepository.GetMessagesAsync(conversationId, page, pageSize, cancellationToken);

        var participant = await dbContext.ConversationParticipants
            .FirstOrDefaultAsync(cp => cp.ConversationId == conversationId && cp.UserId == userId, cancellationToken);

        if (participant is not null)
        {
            participant.LastReadAt = DateTime.UtcNow;
            await dbContext.SaveChangesAsync(cancellationToken);
        }

        return messages
            .OrderBy(m => m.SentAt)
            .Select(m => ToMessageDto(m, userId))
            .ToList();
    }

    public async Task<MessageDto?> SendMessageAsync(Guid userId, SendMessageRequest request, CancellationToken cancellationToken = default)
    {
        if (!await CanAccessConversationAsync(userId, request.ConversationId, cancellationToken))
        {
            return null;
        }

        if (string.IsNullOrWhiteSpace(request.Content))
        {
            return null;
        }

        var message = new Message
        {
            ConversationId = request.ConversationId,
            SenderId = userId,
            Content = request.Content.Trim(),
            Type = request.Type,
            SentAt = DateTime.UtcNow,
            IsSeen = false
        };

        await messageRepository.AddAsync(message, cancellationToken);
        await messageRepository.SaveChangesAsync(cancellationToken);

        var saved = await messageRepository.GetByIdAsync(message.Id, cancellationToken);
        return saved is null ? null : ToMessageDto(saved, userId);
    }

    public async Task<MessageSeenEventDto?> MarkSeenAsync(Guid userId, Guid messageId, CancellationToken cancellationToken = default)
    {
        var message = await messageRepository.GetByIdAsync(messageId, cancellationToken);
        if (message is null)
        {
            return null;
        }

        if (!await CanAccessConversationAsync(userId, message.ConversationId, cancellationToken))
        {
            return null;
        }

        var seenAt = DateTime.UtcNow;

        if (!message.IsSeen && message.SenderId != userId)
        {
            message.IsSeen = true;
            message.SeenAt = seenAt;
        }

        var participant = await dbContext.ConversationParticipants
            .FirstOrDefaultAsync(cp => cp.ConversationId == message.ConversationId && cp.UserId == userId, cancellationToken);

        if (participant is not null)
        {
            participant.LastReadAt = seenAt;
        }

        await dbContext.SaveChangesAsync(cancellationToken);

        return new MessageSeenEventDto
        {
            MessageId = message.Id,
            ConversationId = message.ConversationId,
            SeenByUserId = userId,
            SeenAt = seenAt
        };
    }

    public Task<bool> CanAccessConversationAsync(Guid userId, Guid conversationId, CancellationToken cancellationToken = default)
    {
        return dbContext.ConversationParticipants
            .AsNoTracking()
            .AnyAsync(cp => cp.ConversationId == conversationId && cp.UserId == userId, cancellationToken);
    }

    public async Task<ChatInfoDto?> GetChatInfoAsync(Guid userId, Guid conversationId, CancellationToken cancellationToken = default)
    {
        var conversation = await conversationRepository.GetByIdWithParticipantsAsync(conversationId, cancellationToken);
        if (conversation is null)
        {
            return null;
        }

        var canAccess = conversation.Participants.Any(p => p.UserId == userId);
        if (!canAccess)
        {
            return null;
        }

        var title = ResolveConversationTitle(conversation, userId);
        var messageCount = await conversationRepository.GetMessageCountAsync(conversationId, cancellationToken);

        return new ChatInfoDto
        {
            ConversationId = conversationId,
            IsGroup = conversation.IsGroup,
            Title = title,
            Members = conversation.Participants.Select(p => p.User.Username),
            TotalMessages = messageCount
        };
    }

    public async Task<IReadOnlyList<Guid>> GetConversationParticipantIdsAsync(Guid conversationId, CancellationToken cancellationToken = default)
    {
        return await dbContext.ConversationParticipants
            .AsNoTracking()
            .Where(cp => cp.ConversationId == conversationId)
            .Select(cp => cp.UserId)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<MessageDto>> SearchMessagesAsync(Guid userId, string? query, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(query))
        {
            return [];
        }

        var term = query.Trim().ToLowerInvariant();

        var accessibleConversationIds = dbContext.ConversationParticipants
            .AsNoTracking()
            .Where(cp => cp.UserId == userId)
            .Select(cp => cp.ConversationId);

        var messages = await dbContext.Messages
            .AsNoTracking()
            .Include(m => m.Sender)
            .Where(m => accessibleConversationIds.Contains(m.ConversationId) &&
                        m.Content.ToLower().Contains(term))
            .OrderByDescending(m => m.SentAt)
            .Take(60)
            .ToListAsync(cancellationToken);

        return messages
            .Select(m => ToMessageDto(m, userId))
            .ToList();
    }

    private async Task<ConversationSummaryDto> BuildConversationSummaryAsync(Conversation conversation, Guid currentUserId, CancellationToken cancellationToken)
    {
        var lastMessage = conversation.Messages.OrderByDescending(m => m.SentAt).FirstOrDefault();
        var title = ResolveConversationTitle(conversation, currentUserId);
        var avatar = conversation.IsGroup
            ? null
            : conversation.Participants.FirstOrDefault(p => p.UserId != currentUserId)?.User.AvatarUrl;

        var otherUser = conversation.Participants.FirstOrDefault(p => p.UserId != currentUserId)?.User;
        var unreadCount = await messageRepository.CountUnreadAsync(conversation.Id, currentUserId, cancellationToken);

        return new ConversationSummaryDto
        {
            Id = conversation.Id,
            DisplayName = title,
            AvatarUrl = avatar,
            IsGroup = conversation.IsGroup,
            IsOnline = otherUser is not null && presenceService.IsOnline(otherUser.Id),
            LastMessage = lastMessage?.Content,
            LastMessageAt = lastMessage?.SentAt,
            UnreadCount = unreadCount
        };
    }

    private static string ResolveConversationTitle(Conversation conversation, Guid currentUserId)
    {
        if (conversation.IsGroup)
        {
            return string.IsNullOrWhiteSpace(conversation.Name) ? "Group Chat" : conversation.Name;
        }

        return conversation.Participants
            .FirstOrDefault(p => p.UserId != currentUserId)?.User.Username
               ?? "Direct Chat";
    }

    private static MessageDto ToMessageDto(Message message, Guid currentUserId)
    {
        return new MessageDto
        {
            Id = message.Id,
            ConversationId = message.ConversationId,
            SenderId = message.SenderId,
            SenderName = message.Sender.Username,
            Content = message.Content,
            Type = message.Type,
            SentAt = message.SentAt,
            IsSeen = message.IsSeen,
            SeenAt = message.SeenAt,
            IsMine = message.SenderId == currentUserId
        };
    }
}
