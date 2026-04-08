using System.ComponentModel.DataAnnotations;

namespace RuneChat.Api.DTOs.Users;

public sealed class ChangePasswordRequest
{
    [Required, MinLength(8), MaxLength(80)]
    public string CurrentPassword { get; init; } = string.Empty;

    [Required, MinLength(8), MaxLength(80)]
    public string NewPassword { get; init; } = string.Empty;
}
