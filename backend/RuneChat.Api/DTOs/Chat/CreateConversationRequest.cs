using System.ComponentModel.DataAnnotations;

namespace RuneChat.Api.DTOs.Chat;

public sealed class CreateConversationRequest
{
    [Required]
    public Guid TargetUserId { get; init; }
}
