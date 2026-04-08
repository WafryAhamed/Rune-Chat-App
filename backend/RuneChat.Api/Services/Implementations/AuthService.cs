using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using RuneChat.Api.Configuration;
using RuneChat.Api.Data;
using RuneChat.Api.DTOs.Auth;
using RuneChat.Api.DTOs.Users;
using RuneChat.Api.Models;
using RuneChat.Api.Repositories.Interfaces;
using RuneChat.Api.Services.Interfaces;

namespace RuneChat.Api.Services.Implementations;

public sealed class AuthService(
    IUserRepository userRepository,
    IRefreshTokenRepository refreshTokenRepository,
    ITokenService tokenService,
    IPresenceService presenceService,
    AppDbContext dbContext,
    IOptions<JwtSettings> jwtOptions,
    ILogger<AuthService> logger) : IAuthService
{
    private readonly JwtSettings _jwtSettings = jwtOptions.Value;

    public async Task<AuthResponse?> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken = default)
    {
        if (await userRepository.ExistsByEmailAsync(request.Email, cancellationToken) ||
            await userRepository.ExistsByUsernameAsync(request.Username, cancellationToken))
        {
            return null;
        }

        var user = new AppUser
        {
            Username = request.Username.Trim(),
            Email = request.Email.Trim(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        await userRepository.AddAsync(user, cancellationToken);
        await userRepository.SaveChangesAsync(cancellationToken);

        return await IssueTokensAsync(user, cancellationToken);
    }

    public async Task<AuthResponse?> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default)
    {
        var user = await userRepository.GetByEmailAsync(request.Email, track: true, cancellationToken);
        if (user is null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            return null;
        }

        return await IssueTokensAsync(user, cancellationToken);
    }

    public async Task<AuthResponse?> RefreshAsync(string refreshToken, CancellationToken cancellationToken = default)
    {
        var token = await refreshTokenRepository.GetByTokenAsync(refreshToken, cancellationToken);
        if (token is null || !token.IsActive)
        {
            return null;
        }

        token.RevokedAt = DateTime.UtcNow;
        refreshTokenRepository.Update(token);

        var newToken = tokenService.CreateRefreshToken(token.UserId);
        await refreshTokenRepository.AddAsync(newToken, cancellationToken);
        await refreshTokenRepository.SaveChangesAsync(cancellationToken);

        var user = token.User;
        return new AuthResponse
        {
            AccessToken = tokenService.CreateAccessToken(user),
            RefreshToken = newToken.Token,
            ExpiresInSeconds = _jwtSettings.AccessTokenMinutes * 60,
            User = ToUserDto(user)
        };
    }

    public async Task<bool> ForgotPasswordAsync(string email, CancellationToken cancellationToken = default)
    {
        var user = await userRepository.GetByEmailAsync(email, track: true, cancellationToken);
        if (user is null)
        {
            return true;
        }

        var token = Convert.ToHexString(Guid.NewGuid().ToByteArray()) + Convert.ToHexString(Guid.NewGuid().ToByteArray());
        dbContext.PasswordResetTokens.Add(new PasswordResetToken
        {
            UserId = user.Id,
            Token = token,
            ExpiresAt = DateTime.UtcNow.AddMinutes(30)
        });

        await dbContext.SaveChangesAsync(cancellationToken);

        // In production, send this via email provider.
        logger.LogInformation("Password reset token for {Email}: {Token}", user.Email, token);
        return true;
    }

    public async Task<bool> ResetPasswordAsync(string token, string newPassword, CancellationToken cancellationToken = default)
    {
        var resetToken = await dbContext.PasswordResetTokens
            .Include(pr => pr.User)
            .FirstOrDefaultAsync(pr => pr.Token == token, cancellationToken);

        if (resetToken is null || !resetToken.IsUsable)
        {
            return false;
        }

        resetToken.UsedAt = DateTime.UtcNow;
        resetToken.User.PasswordHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
        resetToken.User.UpdatedAt = DateTime.UtcNow;

        await dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task LogoutAsync(Guid userId, string refreshToken, CancellationToken cancellationToken = default)
    {
        var token = await refreshTokenRepository.GetByTokenAsync(refreshToken, cancellationToken);
        if (token is null || token.UserId != userId)
        {
            return;
        }

        token.RevokedAt = DateTime.UtcNow;
        refreshTokenRepository.Update(token);
        await refreshTokenRepository.SaveChangesAsync(cancellationToken);
    }

    public async Task LogoutAllAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var sessions = await refreshTokenRepository.GetByUserIdAsync(userId, cancellationToken);
        foreach (var session in sessions.Where(s => s.IsActive))
        {
            session.RevokedAt = DateTime.UtcNow;
        }

        await refreshTokenRepository.SaveChangesAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<UserSessionDto>> GetSessionsAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var sessions = await refreshTokenRepository.GetByUserIdAsync(userId, cancellationToken);
        return sessions
            .Select(s => new UserSessionDto
            {
                Id = s.Id,
                CreatedAt = s.CreatedAt,
                ExpiresAt = s.ExpiresAt,
                IsActive = s.IsActive
            })
            .ToList();
    }

    public async Task<bool> RevokeSessionAsync(Guid userId, Guid sessionId, CancellationToken cancellationToken = default)
    {
        var session = await refreshTokenRepository.GetByIdAsync(sessionId, cancellationToken);
        if (session is null || session.UserId != userId)
        {
            return false;
        }

        session.RevokedAt = DateTime.UtcNow;
        refreshTokenRepository.Update(session);
        await refreshTokenRepository.SaveChangesAsync(cancellationToken);
        return true;
    }

    private async Task<AuthResponse> IssueTokensAsync(AppUser user, CancellationToken cancellationToken)
    {
        var refreshToken = tokenService.CreateRefreshToken(user.Id);
        await refreshTokenRepository.AddAsync(refreshToken, cancellationToken);
        await refreshTokenRepository.SaveChangesAsync(cancellationToken);

        return new AuthResponse
        {
            AccessToken = tokenService.CreateAccessToken(user),
            RefreshToken = refreshToken.Token,
            ExpiresInSeconds = _jwtSettings.AccessTokenMinutes * 60,
            User = ToUserDto(user)
        };
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
