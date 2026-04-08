using System.ComponentModel.DataAnnotations;

namespace RuneChat.Api.DTOs.Users;

public sealed class UpdateProfileRequest
{
    [MaxLength(50)]
    public string? Username { get; init; }

    [MaxLength(200)]
    public string? Bio { get; init; }

    [MaxLength(400)]
    public string? AvatarUrl { get; init; }
}
