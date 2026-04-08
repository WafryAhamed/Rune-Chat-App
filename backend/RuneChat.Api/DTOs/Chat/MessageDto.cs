using RuneChat.Api.Models;

namespace RuneChat.Api.DTOs.Chat;

public sealed class MessageDto
{
    public Guid Id { get; init; }
    public Guid ConversationId { get; init; }
    public Guid SenderId { get; init; }
    public string SenderName { get; init; } = string.Empty;
    public string Content { get; init; } = string.Empty;
    public MessageType Type { get; init; }
    public DateTime SentAt { get; init; }
    public bool IsSeen { get; init; }
    public DateTime? SeenAt { get; init; }
    public bool IsMine { get; init; }
}
