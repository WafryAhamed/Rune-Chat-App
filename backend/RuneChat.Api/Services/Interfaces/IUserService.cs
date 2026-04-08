using RuneChat.Api.DTOs.Users;

namespace RuneChat.Api.Services.Interfaces;

public interface IUserService
{
    Task<UserDto?> GetMeAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<UserDto>> SearchUsersAsync(Guid userId, string? query, CancellationToken cancellationToken = default);
    Task<UserDto?> UpdateProfileAsync(Guid userId, UpdateProfileRequest request, CancellationToken cancellationToken = default);
    Task<bool> ChangePasswordAsync(Guid userId, string currentPassword, string newPassword, CancellationToken cancellationToken = default);
    Task<bool> BlockUserAsync(Guid userId, Guid blockedUserId, CancellationToken cancellationToken = default);
    Task<bool> UnblockUserAsync(Guid userId, Guid blockedUserId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<UserDto>> GetBlockedUsersAsync(Guid userId, CancellationToken cancellationToken = default);
}
