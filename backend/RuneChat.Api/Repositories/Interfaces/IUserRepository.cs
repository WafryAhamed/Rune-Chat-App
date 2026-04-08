using RuneChat.Api.Models;

namespace RuneChat.Api.Repositories.Interfaces;

public interface IUserRepository
{
    Task<AppUser?> GetByIdAsync(Guid id, bool track = true, CancellationToken cancellationToken = default);
    Task<AppUser?> GetByEmailAsync(string email, bool track = true, CancellationToken cancellationToken = default);
    Task<AppUser?> GetByUsernameAsync(string username, bool track = true, CancellationToken cancellationToken = default);
    Task<bool> ExistsByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<bool> ExistsByUsernameAsync(string username, CancellationToken cancellationToken = default);
    Task<List<AppUser>> SearchUsersAsync(string? query, Guid excludeUserId, CancellationToken cancellationToken = default);
    Task<List<AppUser>> GetByIdsAsync(IEnumerable<Guid> ids, CancellationToken cancellationToken = default);
    Task AddAsync(AppUser user, CancellationToken cancellationToken = default);
    void Update(AppUser user);
    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}
