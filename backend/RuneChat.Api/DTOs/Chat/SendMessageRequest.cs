using System.ComponentModel.DataAnnotations;
using RuneChat.Api.Models;

namespace RuneChat.Api.DTOs.Chat;

public sealed class SendMessageRequest
{
    [Required]
    public Guid ConversationId { get; init; }

    [Required, MaxLength(3000)]
    public string Content { get; init; } = string.Empty;

    public MessageType Type { get; init; } = MessageType.Text;
}
