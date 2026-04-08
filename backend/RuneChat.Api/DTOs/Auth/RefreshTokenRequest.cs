using System.ComponentModel.DataAnnotations;

namespace RuneChat.Api.DTOs.Auth;

public sealed class RefreshTokenRequest
{
    [Required]
    public string RefreshToken { get; init; } = string.Empty;
}
