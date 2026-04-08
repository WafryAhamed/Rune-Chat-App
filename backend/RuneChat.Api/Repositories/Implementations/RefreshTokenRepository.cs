using Microsoft.EntityFrameworkCore;
using RuneChat.Api.Data;
using RuneChat.Api.Models;
using RuneChat.Api.Repositories.Interfaces;

namespace RuneChat.Api.Repositories.Implementations;

public sealed class RefreshTokenRepository(AppDbContext dbContext) : IRefreshTokenRepository
{
    public Task AddAsync(RefreshToken token, CancellationToken cancellationToken = default)
    {
        return dbContext.RefreshTokens.AddAsync(token, cancellationToken).AsTask();
    }

    public Task<RefreshToken?> GetByTokenAsync(string token, CancellationToken cancellationToken = default)
    {
        return dbContext.RefreshTokens
            .Include(rt => rt.User)
            .FirstOrDefaultAsync(rt => rt.Token == token, cancellationToken);
    }

    public Task<List<RefreshToken>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return dbContext.RefreshTokens
            .AsNoTracking()
            .Where(rt => rt.UserId == userId)
            .OrderByDescending(rt => rt.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public Task<RefreshToken?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return dbContext.RefreshTokens
            .FirstOrDefaultAsync(rt => rt.Id == id, cancellationToken);
    }

    public void Update(RefreshToken token)
    {
        dbContext.RefreshTokens.Update(token);
    }

    public Task SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return dbContext.SaveChangesAsync(cancellationToken);
    }
}
