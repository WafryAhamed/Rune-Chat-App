namespace RuneChat.Api.DTOs.Users;

public sealed class UserDto
{
    public Guid Id { get; init; }
    public string Username { get; init; } = string.Empty;
    public string Email { get; init; } = string.Empty;
    public string? Bio { get; init; }
    public string? AvatarUrl { get; init; }
    public bool IsOnline { get; init; }
}
