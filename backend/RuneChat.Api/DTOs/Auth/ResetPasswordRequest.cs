using System.ComponentModel.DataAnnotations;

namespace RuneChat.Api.DTOs.Auth;

public sealed class ResetPasswordRequest
{
    [Required]
    public string Token { get; init; } = string.Empty;

    [Required, MinLength(8), MaxLength(80)]
    public string NewPassword { get; init; } = string.Empty;
}
