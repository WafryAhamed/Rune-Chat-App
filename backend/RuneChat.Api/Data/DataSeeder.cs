using Microsoft.EntityFrameworkCore;
using RuneChat.Api.Models;

namespace RuneChat.Api.Data;

public sealed class DataSeeder(AppDbContext dbContext)
{
    public async Task SeedAsync(CancellationToken cancellationToken = default)
    {
        if (await dbContext.Users.AnyAsync(cancellationToken))
        {
            return;
        }

        var alice = new AppUser
        {
            Username = "ධනිෂ්ඨ",
            Email = "alice@runechat.dev",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Alice@123"),
            Bio = "ශ්‍රී ලංකා තරුණ සඳහර ✨"
        };

        var bob = new AppUser
        {
            Username = "රිතුසය",
            Email = "bob@runechat.dev",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Bob@123"),
            Bio = "ශ්‍රී ලංකා පිහිඹුවෙන භ්‍රමණය"
        };

        var conversation = new Conversation
        {
            IsGroup = false,
            Name = null,
            Participants =
            {
                new ConversationParticipant { User = alice, LastReadAt = DateTime.UtcNow },
                new ConversationParticipant { User = bob, LastReadAt = DateTime.UtcNow }
            },
            Messages =
            {
                new Message
                {
                    Sender = alice,
                    Content = "සිංහල සන්නිවේදනයට ස්වාගතයි. සැබෑ-කාලීන, ගෝපනීය, සහ මනරම්.",
                    Type = MessageType.System,
                    IsSeen = true,
                    SeenAt = DateTime.UtcNow
                }
            }
        };

        dbContext.Users.AddRange(alice, bob);
        dbContext.Conversations.Add(conversation);
        await dbContext.SaveChangesAsync(cancellationToken);
    }
}
