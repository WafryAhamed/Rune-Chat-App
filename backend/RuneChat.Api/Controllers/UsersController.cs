using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RuneChat.Api.DTOs.Users;
using RuneChat.Api.Extensions;
using RuneChat.Api.Services.Interfaces;

namespace RuneChat.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public sealed class UsersController(IUserService userService) : ControllerBase
{
    [HttpGet("me")]
    public async Task<IActionResult> GetMe(CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var user = await userService.GetMeAsync(userId.Value, cancellationToken);
        return user is null ? NotFound() : Ok(user);
    }

    [HttpGet]
    public async Task<IActionResult> Search([FromQuery] string? query, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var users = await userService.SearchUsersAsync(userId.Value, query, cancellationToken);
        return Ok(users);
    }

    [HttpPut("me")]
    public async Task<IActionResult> Update([FromBody] UpdateProfileRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var user = await userService.UpdateProfileAsync(userId.Value, request, cancellationToken);
        return user is null ? BadRequest(new { message = "Profile update failed." }) : Ok(user);
    }

    [HttpPost("change-password")]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var success = await userService.ChangePasswordAsync(userId.Value, request.CurrentPassword, request.NewPassword, cancellationToken);
        return success ? NoContent() : BadRequest(new { message = "Password change failed." });
    }

    [HttpPost("block/{blockedUserId:guid}")]
    public async Task<IActionResult> Block([FromRoute] Guid blockedUserId, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var success = await userService.BlockUserAsync(userId.Value, blockedUserId, cancellationToken);
        return success ? NoContent() : BadRequest();
    }

    [HttpDelete("block/{blockedUserId:guid}")]
    public async Task<IActionResult> Unblock([FromRoute] Guid blockedUserId, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var success = await userService.UnblockUserAsync(userId.Value, blockedUserId, cancellationToken);
        return success ? NoContent() : NotFound();
    }

    [HttpGet("blocked")]
    public async Task<IActionResult> Blocked(CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var users = await userService.GetBlockedUsersAsync(userId.Value, cancellationToken);
        return Ok(users);
    }
}
