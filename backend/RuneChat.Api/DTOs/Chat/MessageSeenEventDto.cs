namespace RuneChat.Api.DTOs.Chat;

public sealed class MessageSeenEventDto
{
    public Guid MessageId { get; init; }
    public Guid ConversationId { get; init; }
    public Guid SeenByUserId { get; init; }
    public DateTime SeenAt { get; init; }
}
