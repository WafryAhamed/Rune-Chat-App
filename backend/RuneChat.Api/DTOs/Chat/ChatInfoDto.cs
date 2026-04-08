namespace RuneChat.Api.DTOs.Chat;

public sealed class ChatInfoDto
{
    public Guid ConversationId { get; init; }
    public bool IsGroup { get; init; }
    public string Title { get; init; } = string.Empty;
    public IEnumerable<string> Members { get; init; } = Array.Empty<string>();
    public int TotalMessages { get; init; }
}
