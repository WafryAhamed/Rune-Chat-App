using System.ComponentModel.DataAnnotations;

namespace RuneChat.Api.Models;

public sealed class AppUser
{
    public Guid Id { get; set; } = Guid.NewGuid();

    [MaxLength(50)]
    public string Username { get; set; } = string.Empty;

    [MaxLength(120)]
    public string Email { get; set; } = string.Empty;

    [MaxLength(300)]
    public string PasswordHash { get; set; } = string.Empty;

    [MaxLength(200)]
    public string? Bio { get; set; }

    [MaxLength(400)]
    public string? AvatarUrl { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<ConversationParticipant> ConversationParticipants { get; set; } = new List<ConversationParticipant>();
    public ICollection<Message> SentMessages { get; set; } = new List<Message>();
    public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
    public ICollection<Notification> Notifications { get; set; } = new List<Notification>();

    public ICollection<UserBlock> BlocksInitiated { get; set; } = new List<UserBlock>();
    public ICollection<UserBlock> BlocksReceived { get; set; } = new List<UserBlock>();
}
