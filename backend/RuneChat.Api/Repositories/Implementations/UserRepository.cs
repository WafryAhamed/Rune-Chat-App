using Microsoft.EntityFrameworkCore;
using RuneChat.Api.Data;
using RuneChat.Api.Models;
using RuneChat.Api.Repositories.Interfaces;

namespace RuneChat.Api.Repositories.Implementations;

public sealed class UserRepository(AppDbContext dbContext) : IUserRepository
{
    public async Task<AppUser?> GetByIdAsync(Guid id, bool track = true, CancellationToken cancellationToken = default)
    {
        var query = dbContext.Users.AsQueryable();
        if (!track)
        {
            query = query.AsNoTracking();
        }

        return await query.FirstOrDefaultAsync(u => u.Id == id, cancellationToken);
    }

    public async Task<AppUser?> GetByEmailAsync(string email, bool track = true, CancellationToken cancellationToken = default)
    {
        var query = dbContext.Users.AsQueryable();
        if (!track)
        {
            query = query.AsNoTracking();
        }

        var normalized = email.ToLowerInvariant();
        return await query.FirstOrDefaultAsync(u => u.Email == normalized, cancellationToken);
    }

    public async Task<AppUser?> GetByUsernameAsync(string username, bool track = true, CancellationToken cancellationToken = default)
    {
        var query = dbContext.Users.AsQueryable();
        if (!track)
        {
            query = query.AsNoTracking();
        }

        return await query.FirstOrDefaultAsync(u => u.Username == username, cancellationToken);
    }

    public Task<bool> ExistsByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        var normalized = email.ToLowerInvariant();
        return dbContext.Users.AnyAsync(u => u.Email == normalized, cancellationToken);
    }

    public Task<bool> ExistsByUsernameAsync(string username, CancellationToken cancellationToken = default)
    {
        return dbContext.Users.AnyAsync(u => u.Username == username, cancellationToken);
    }

    public Task<List<AppUser>> SearchUsersAsync(string? query, Guid excludeUserId, CancellationToken cancellationToken = default)
    {
        var q = dbContext.Users
            .AsNoTracking()
            .Where(u => u.Id != excludeUserId);

        if (!string.IsNullOrWhiteSpace(query))
        {
            var term = query.Trim().ToLowerInvariant();
            q = q.Where(u => u.Username.ToLower().Contains(term) || u.Email.ToLower().Contains(term));
        }

        return q
            .OrderBy(u => u.Username)
            .Take(50)
            .ToListAsync(cancellationToken);
    }

    public Task<List<AppUser>> GetByIdsAsync(IEnumerable<Guid> ids, CancellationToken cancellationToken = default)
    {
        var set = ids.Distinct().ToList();
        return dbContext.Users
            .AsNoTracking()
            .Where(u => set.Contains(u.Id))
            .ToListAsync(cancellationToken);
    }

    public Task AddAsync(AppUser user, CancellationToken cancellationToken = default)
    {
        return dbContext.Users.AddAsync(user, cancellationToken).AsTask();
    }

    public void Update(AppUser user)
    {
        dbContext.Users.Update(user);
    }

    public Task SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return dbContext.SaveChangesAsync(cancellationToken);
    }
}
