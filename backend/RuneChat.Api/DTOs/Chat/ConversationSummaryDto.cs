namespace RuneChat.Api.DTOs.Chat;

public sealed class ConversationSummaryDto
{
    public Guid Id { get; init; }
    public string DisplayName { get; init; } = string.Empty;
    public string? AvatarUrl { get; init; }
    public bool IsGroup { get; init; }
    public bool IsOnline { get; init; }
    public string? LastMessage { get; init; }
    public DateTime? LastMessageAt { get; init; }
    public int UnreadCount { get; init; }
}
