namespace RuneChat.Api.DTOs.Chat;

public sealed class TypingEventDto
{
    public Guid ConversationId { get; init; }
    public Guid UserId { get; init; }
    public bool IsTyping { get; init; }
}
