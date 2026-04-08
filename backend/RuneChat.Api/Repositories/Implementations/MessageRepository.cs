using Microsoft.EntityFrameworkCore;
using RuneChat.Api.Data;
using RuneChat.Api.Models;
using RuneChat.Api.Repositories.Interfaces;

namespace RuneChat.Api.Repositories.Implementations;

public sealed class MessageRepository(AppDbContext dbContext) : IMessageRepository
{
    public Task AddAsync(Message message, CancellationToken cancellationToken = default)
    {
        return dbContext.Messages.AddAsync(message, cancellationToken).AsTask();
    }

    public Task<List<Message>> GetMessagesAsync(Guid conversationId, int page, int pageSize, CancellationToken cancellationToken = default)
    {
        var safePage = Math.Max(1, page);
        var safePageSize = Math.Clamp(pageSize, 1, 100);

        return dbContext.Messages
            .AsNoTracking()
            .Include(m => m.Sender)
            .Where(m => m.ConversationId == conversationId)
            .OrderByDescending(m => m.SentAt)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .ToListAsync(cancellationToken);
    }

    public Task<Message?> GetByIdAsync(Guid messageId, CancellationToken cancellationToken = default)
    {
        return dbContext.Messages
            .Include(m => m.Sender)
            .FirstOrDefaultAsync(m => m.Id == messageId, cancellationToken);
    }

    public async Task<int> CountUnreadAsync(Guid conversationId, Guid userId, CancellationToken cancellationToken = default)
    {
        var participant = await dbContext.ConversationParticipants
            .AsNoTracking()
            .FirstOrDefaultAsync(cp => cp.ConversationId == conversationId && cp.UserId == userId, cancellationToken);

        var lastReadAt = participant?.LastReadAt ?? DateTime.MinValue;

        return await dbContext.Messages
            .AsNoTracking()
            .Where(m => m.ConversationId == conversationId && m.SenderId != userId && m.SentAt > lastReadAt)
            .CountAsync(cancellationToken);
    }

    public Task SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return dbContext.SaveChangesAsync(cancellationToken);
    }
}
