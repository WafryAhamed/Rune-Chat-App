using Microsoft.EntityFrameworkCore;
using RuneChat.Api.Data;
using RuneChat.Api.Models;
using RuneChat.Api.Repositories.Interfaces;

namespace RuneChat.Api.Repositories.Implementations;

public sealed class ConversationRepository(AppDbContext dbContext) : IConversationRepository
{
    public Task<Conversation?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return dbContext.Conversations
            .AsNoTracking()
            .FirstOrDefaultAsync(c => c.Id == id, cancellationToken);
    }

    public Task<Conversation?> GetByIdWithParticipantsAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return dbContext.Conversations
            .Include(c => c.Participants)
                .ThenInclude(cp => cp.User)
            .Include(c => c.Messages.OrderByDescending(m => m.SentAt).Take(1))
                .ThenInclude(m => m.Sender)
            .FirstOrDefaultAsync(c => c.Id == id, cancellationToken);
    }

    public Task<Conversation?> GetPrivateConversationAsync(Guid userId, Guid targetUserId, CancellationToken cancellationToken = default)
    {
        return dbContext.Conversations
            .Include(c => c.Participants)
            .Where(c => !c.IsGroup)
            .FirstOrDefaultAsync(c => c.Participants.Any(p => p.UserId == userId)
                                   && c.Participants.Any(p => p.UserId == targetUserId)
                                   && c.Participants.Count == 2,
                cancellationToken);
    }

    public Task<List<Conversation>> GetUserConversationsAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return dbContext.Conversations
            .AsNoTracking()
            .Include(c => c.Participants)
                .ThenInclude(cp => cp.User)
            .Include(c => c.Messages.OrderByDescending(m => m.SentAt).Take(1))
                .ThenInclude(m => m.Sender)
            .Where(c => c.Participants.Any(p => p.UserId == userId))
            .OrderByDescending(c => c.Messages.Max(m => (DateTime?)m.SentAt) ?? c.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public Task<int> GetMessageCountAsync(Guid conversationId, CancellationToken cancellationToken = default)
    {
        return dbContext.Messages.CountAsync(m => m.ConversationId == conversationId, cancellationToken);
    }

    public Task AddAsync(Conversation conversation, CancellationToken cancellationToken = default)
    {
        return dbContext.Conversations.AddAsync(conversation, cancellationToken).AsTask();
    }

    public Task SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return dbContext.SaveChangesAsync(cancellationToken);
    }
}
