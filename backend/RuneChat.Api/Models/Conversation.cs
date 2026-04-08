using System.ComponentModel.DataAnnotations;

namespace RuneChat.Api.Models;

public sealed class Conversation
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public bool IsGroup { get; set; }

    [MaxLength(80)]
    public string? Name { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<ConversationParticipant> Participants { get; set; } = new List<ConversationParticipant>();
    public ICollection<Message> Messages { get; set; } = new List<Message>();
}
