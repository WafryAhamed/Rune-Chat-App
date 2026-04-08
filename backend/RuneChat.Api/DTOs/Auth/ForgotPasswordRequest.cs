using System.ComponentModel.DataAnnotations;

namespace RuneChat.Api.DTOs.Auth;

public sealed class ForgotPasswordRequest
{
    [Required, EmailAddress]
    public string Email { get; init; } = string.Empty;
}
