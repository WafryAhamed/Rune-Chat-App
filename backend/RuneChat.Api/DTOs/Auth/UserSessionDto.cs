namespace RuneChat.Api.DTOs.Auth;

public sealed class UserSessionDto
{
    public Guid Id { get; init; }
    public DateTime CreatedAt { get; init; }
    public DateTime ExpiresAt { get; init; }
    public bool IsActive { get; init; }
}
