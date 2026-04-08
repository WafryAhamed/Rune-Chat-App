using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RuneChat.Api.Extensions;
using RuneChat.Api.Services.Interfaces;

namespace RuneChat.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public sealed class NotificationsController(INotificationService notificationService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> Get(CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var notifications = await notificationService.GetForUserAsync(userId.Value, cancellationToken);
        return Ok(notifications);
    }

    [HttpPost("{notificationId:guid}/read")]
    public async Task<IActionResult> MarkRead([FromRoute] Guid notificationId, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var success = await notificationService.MarkReadAsync(userId.Value, notificationId, cancellationToken);
        return success ? NoContent() : NotFound();
    }
}
