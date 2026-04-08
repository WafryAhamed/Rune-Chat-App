using Microsoft.EntityFrameworkCore;
using RuneChat.Api.Data;
using RuneChat.Api.Models;
using RuneChat.Api.Repositories.Interfaces;

namespace RuneChat.Api.Repositories.Implementations;

public sealed class UserBlockRepository(AppDbContext dbContext) : IUserBlockRepository
{
    public Task<bool> IsEitherBlockedAsync(Guid userA, Guid userB, CancellationToken cancellationToken = default)
    {
        return dbContext.UserBlocks.AnyAsync(
            b => (b.BlockerId == userA && b.BlockedUserId == userB) ||
                 (b.BlockerId == userB && b.BlockedUserId == userA),
            cancellationToken);
    }

    public Task<UserBlock?> GetBlockAsync(Guid blockerId, Guid blockedUserId, CancellationToken cancellationToken = default)
    {
        return dbContext.UserBlocks.FirstOrDefaultAsync(
            b => b.BlockerId == blockerId && b.BlockedUserId == blockedUserId,
            cancellationToken);
    }

    public Task<List<UserBlock>> GetBlockedUsersAsync(Guid blockerId, CancellationToken cancellationToken = default)
    {
        return dbContext.UserBlocks
            .AsNoTracking()
            .Include(b => b.BlockedUser)
            .Where(b => b.BlockerId == blockerId)
            .OrderByDescending(b => b.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public Task AddAsync(UserBlock block, CancellationToken cancellationToken = default)
    {
        return dbContext.UserBlocks.AddAsync(block, cancellationToken).AsTask();
    }

    public void Remove(UserBlock block)
    {
        dbContext.UserBlocks.Remove(block);
    }

    public Task SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return dbContext.SaveChangesAsync(cancellationToken);
    }
}
