using RuneChat.Api.Models;

namespace RuneChat.Api.Repositories.Interfaces;

public interface IRefreshTokenRepository
{
    Task AddAsync(RefreshToken token, CancellationToken cancellationToken = default);
    Task<RefreshToken?> GetByTokenAsync(string token, CancellationToken cancellationToken = default);
    Task<List<RefreshToken>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<RefreshToken?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    void Update(RefreshToken token);
    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}
