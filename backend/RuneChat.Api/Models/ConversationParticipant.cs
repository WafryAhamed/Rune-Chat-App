namespace RuneChat.Api.Models;

public sealed class ConversationParticipant
{
    public Guid ConversationId { get; set; }
    public Conversation Conversation { get; set; } = default!;

    public Guid UserId { get; set; }
    public AppUser User { get; set; } = default!;

    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;
    public DateTime? LastReadAt { get; set; }
}
