using RuneChat.Api.DTOs.Users;

namespace RuneChat.Api.DTOs.Auth;

public sealed class AuthResponse
{
    public string AccessToken { get; init; } = string.Empty;
    public string RefreshToken { get; init; } = string.Empty;
    public long ExpiresInSeconds { get; init; }
    public UserDto User { get; init; } = default!;
}
