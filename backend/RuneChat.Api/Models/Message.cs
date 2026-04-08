using System.ComponentModel.DataAnnotations;

namespace RuneChat.Api.Models;

public sealed class Message
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid ConversationId { get; set; }
    public Conversation Conversation { get; set; } = default!;

    public Guid SenderId { get; set; }
    public AppUser Sender { get; set; } = default!;

    [MaxLength(3000)]
    public string Content { get; set; } = string.Empty;

    public MessageType Type { get; set; } = MessageType.Text;
    public DateTime SentAt { get; set; } = DateTime.UtcNow;

    public bool IsSeen { get; set; }
    public DateTime? SeenAt { get; set; }
}
