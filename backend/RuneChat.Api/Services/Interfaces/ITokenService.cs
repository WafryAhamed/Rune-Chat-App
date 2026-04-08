using RuneChat.Api.Models;

namespace RuneChat.Api.Services.Interfaces;

public interface ITokenService
{
    string CreateAccessToken(AppUser user);
    RefreshToken CreateRefreshToken(Guid userId);
}
