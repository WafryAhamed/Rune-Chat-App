using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RuneChat.Api.DTOs.Auth;
using RuneChat.Api.Extensions;
using RuneChat.Api.Services.Interfaces;

namespace RuneChat.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class AuthController(IAuthService authService) : ControllerBase
{
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        var result = await authService.RegisterAsync(request, cancellationToken);
        if (result is null)
        {
            return Conflict(new { message = "Email or username already exists." });
        }

        return Ok(result);
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        var result = await authService.LoginAsync(request, cancellationToken);
        if (result is null)
        {
            return Unauthorized(new { message = "Invalid credentials." });
        }

        return Ok(result);
    }

    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequest request, CancellationToken cancellationToken)
    {
        var result = await authService.RefreshAsync(request.RefreshToken, cancellationToken);
        if (result is null)
        {
            return Unauthorized(new { message = "Invalid refresh token." });
        }

        return Ok(result);
    }

    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        await authService.ForgotPasswordAsync(request.Email, cancellationToken);
        return Ok(new { message = "If the email exists, a reset link was generated." });
    }

    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request, CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        var success = await authService.ResetPasswordAsync(request.Token, request.NewPassword, cancellationToken);
        return success ? Ok(new { message = "Password reset successful." }) : BadRequest(new { message = "Invalid or expired token." });
    }

    [Authorize]
    [HttpPost("logout")]
    public async Task<IActionResult> Logout([FromBody] RefreshTokenRequest request, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        await authService.LogoutAsync(userId.Value, request.RefreshToken, cancellationToken);
        return NoContent();
    }

    [Authorize]
    [HttpPost("logout-all")]
    public async Task<IActionResult> LogoutAll(CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        await authService.LogoutAllAsync(userId.Value, cancellationToken);
        return NoContent();
    }

    [Authorize]
    [HttpGet("sessions")]
    public async Task<IActionResult> Sessions(CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var sessions = await authService.GetSessionsAsync(userId.Value, cancellationToken);
        return Ok(sessions);
    }

    [Authorize]
    [HttpDelete("sessions/{sessionId:guid}")]
    public async Task<IActionResult> RevokeSession([FromRoute] Guid sessionId, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var success = await authService.RevokeSessionAsync(userId.Value, sessionId, cancellationToken);
        return success ? NoContent() : NotFound();
    }
}
