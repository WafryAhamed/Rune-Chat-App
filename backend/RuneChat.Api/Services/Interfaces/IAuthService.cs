using RuneChat.Api.DTOs.Auth;

namespace RuneChat.Api.Services.Interfaces;

public interface IAuthService
{
    Task<AuthResponse?> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken = default);
    Task<AuthResponse?> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default);
    Task<AuthResponse?> RefreshAsync(string refreshToken, CancellationToken cancellationToken = default);
    Task<bool> ForgotPasswordAsync(string email, CancellationToken cancellationToken = default);
    Task<bool> ResetPasswordAsync(string token, string newPassword, CancellationToken cancellationToken = default);
    Task LogoutAsync(Guid userId, string refreshToken, CancellationToken cancellationToken = default);
    Task LogoutAllAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<UserSessionDto>> GetSessionsAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<bool> RevokeSessionAsync(Guid userId, Guid sessionId, CancellationToken cancellationToken = default);
}
