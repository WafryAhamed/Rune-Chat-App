namespace RuneChat.Api.Models;

public sealed class UserBlock
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid BlockerId { get; set; }
    public AppUser Blocker { get; set; } = default!;

    public Guid BlockedUserId { get; set; }
    public AppUser BlockedUser { get; set; } = default!;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
