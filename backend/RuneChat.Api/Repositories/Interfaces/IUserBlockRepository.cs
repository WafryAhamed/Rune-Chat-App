using RuneChat.Api.Models;

namespace RuneChat.Api.Repositories.Interfaces;

public interface IUserBlockRepository
{
    Task<bool> IsEitherBlockedAsync(Guid userA, Guid userB, CancellationToken cancellationToken = default);
    Task<UserBlock?> GetBlockAsync(Guid blockerId, Guid blockedUserId, CancellationToken cancellationToken = default);
    Task<List<UserBlock>> GetBlockedUsersAsync(Guid blockerId, CancellationToken cancellationToken = default);
    Task AddAsync(UserBlock block, CancellationToken cancellationToken = default);
    void Remove(UserBlock block);
    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}
