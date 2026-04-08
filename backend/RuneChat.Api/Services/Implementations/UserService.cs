using RuneChat.Api.DTOs.Users;
using RuneChat.Api.Models;
using RuneChat.Api.Repositories.Interfaces;
using RuneChat.Api.Services.Interfaces;

namespace RuneChat.Api.Services.Implementations;

public sealed class UserService(
    IUserRepository userRepository,
    IUserBlockRepository userBlockRepository,
    IPresenceService presenceService) : IUserService
{
    public async Task<UserDto?> GetMeAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await userRepository.GetByIdAsync(userId, track: false, cancellationToken);
        return user is null ? null : ToUserDto(user);
    }

    public async Task<IReadOnlyList<UserDto>> SearchUsersAsync(Guid userId, string? query, CancellationToken cancellationToken = default)
    {
        var users = await userRepository.SearchUsersAsync(query, userId, cancellationToken);
        var blocked = await userBlockRepository.GetBlockedUsersAsync(userId, cancellationToken);
        var blockedIds = blocked.Select(b => b.BlockedUserId).ToHashSet();

        return users
            .Where(u => !blockedIds.Contains(u.Id))
            .Select(ToUserDto)
            .ToList();
    }

    public async Task<UserDto?> UpdateProfileAsync(Guid userId, UpdateProfileRequest request, CancellationToken cancellationToken = default)
    {
        var user = await userRepository.GetByIdAsync(userId, track: true, cancellationToken);
        if (user is null)
        {
            return null;
        }

        if (!string.IsNullOrWhiteSpace(request.Username) &&
            !request.Username.Equals(user.Username, StringComparison.OrdinalIgnoreCase))
        {
            if (await userRepository.ExistsByUsernameAsync(request.Username, cancellationToken))
            {
                return null;
            }

            user.Username = request.Username.Trim();
        }

        if (request.Bio is not null)
        {
            user.Bio = request.Bio.Trim();
        }

        if (request.AvatarUrl is not null)
        {
            user.AvatarUrl = request.AvatarUrl.Trim();
        }

        user.UpdatedAt = DateTime.UtcNow;
        userRepository.Update(user);
        await userRepository.SaveChangesAsync(cancellationToken);

        return ToUserDto(user);
    }

    public async Task<bool> ChangePasswordAsync(Guid userId, string currentPassword, string newPassword, CancellationToken cancellationToken = default)
    {
        var user = await userRepository.GetByIdAsync(userId, track: true, cancellationToken);
        if (user is null || !BCrypt.Net.BCrypt.Verify(currentPassword, user.PasswordHash))
        {
            return false;
        }

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
        user.UpdatedAt = DateTime.UtcNow;
        userRepository.Update(user);
        await userRepository.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> BlockUserAsync(Guid userId, Guid blockedUserId, CancellationToken cancellationToken = default)
    {
        if (userId == blockedUserId)
        {
            return false;
        }

        var target = await userRepository.GetByIdAsync(blockedUserId, track: false, cancellationToken);
        if (target is null)
        {
            return false;
        }

        var existing = await userBlockRepository.GetBlockAsync(userId, blockedUserId, cancellationToken);
        if (existing is not null)
        {
            return true;
        }

        await userBlockRepository.AddAsync(new UserBlock
        {
            BlockerId = userId,
            BlockedUserId = blockedUserId,
            CreatedAt = DateTime.UtcNow
        }, cancellationToken);

        await userBlockRepository.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> UnblockUserAsync(Guid userId, Guid blockedUserId, CancellationToken cancellationToken = default)
    {
        var block = await userBlockRepository.GetBlockAsync(userId, blockedUserId, cancellationToken);
        if (block is null)
        {
            return false;
        }

        userBlockRepository.Remove(block);
        await userBlockRepository.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<IReadOnlyList<UserDto>> GetBlockedUsersAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var blocks = await userBlockRepository.GetBlockedUsersAsync(userId, cancellationToken);
        return blocks.Select(b => ToUserDto(b.BlockedUser)).ToList();
    }

    private UserDto ToUserDto(AppUser user)
    {
        return new UserDto
        {
            Id = user.Id,
            Username = user.Username,
            Email = user.Email,
            Bio = user.Bio,
            AvatarUrl = user.AvatarUrl,
            IsOnline = presenceService.IsOnline(user.Id)
        };
    }
}
