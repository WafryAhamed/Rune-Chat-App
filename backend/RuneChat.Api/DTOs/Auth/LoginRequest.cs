using System.ComponentModel.DataAnnotations;

namespace RuneChat.Api.DTOs.Auth;

public sealed class LoginRequest
{
    [Required, EmailAddress, MaxLength(120)]
    public string Email { get; init; } = string.Empty;

    [Required, MinLength(8), MaxLength(80)]
    public string Password { get; init; } = string.Empty;
}
