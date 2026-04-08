using RuneChat.Api.DTOs.Users;

namespace RuneChat.Api.DTOs.Chat;

public sealed class GlobalSearchResultDto
{
    public IEnumerable<UserDto> Users { get; init; } = [];
    public IEnumerable<ConversationSummaryDto> Conversations { get; init; } = [];
    public IEnumerable<MessageDto> Messages { get; init; } = [];
}
