using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RuneChat.Api.DTOs.Chat;
using RuneChat.Api.Extensions;
using RuneChat.Api.Services.Interfaces;

namespace RuneChat.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public sealed class ConversationsController(IChatService chatService, IUserService userService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetConversations(CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var conversations = await chatService.GetConversationsAsync(userId.Value, cancellationToken);
        return Ok(conversations);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateConversationRequest request, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var conversation = await chatService.CreateOrGetPrivateConversationAsync(userId.Value, request.TargetUserId, cancellationToken);
        return conversation is null ? BadRequest(new { message = "Cannot create conversation." }) : Ok(conversation);
    }

    [HttpGet("{conversationId:guid}/messages")]
    public async Task<IActionResult> Messages([FromRoute] Guid conversationId, [FromQuery] int page = 1, [FromQuery] int pageSize = 30, CancellationToken cancellationToken = default)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var messages = await chatService.GetMessagesAsync(userId.Value, conversationId, page, pageSize, cancellationToken);
        return Ok(messages);
    }

    [HttpPost("send")]
    public async Task<IActionResult> Send([FromBody] SendMessageRequest request, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var message = await chatService.SendMessageAsync(userId.Value, request, cancellationToken);
        return message is null ? BadRequest(new { message = "Message failed to send." }) : Ok(message);
    }

    [HttpPost("seen/{messageId:guid}")]
    public async Task<IActionResult> Seen([FromRoute] Guid messageId, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var seen = await chatService.MarkSeenAsync(userId.Value, messageId, cancellationToken);
        return seen is null ? NotFound() : Ok(seen);
    }

    [HttpGet("{conversationId:guid}/info")]
    public async Task<IActionResult> Info([FromRoute] Guid conversationId, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var info = await chatService.GetChatInfoAsync(userId.Value, conversationId, cancellationToken);
        return info is null ? NotFound() : Ok(info);
    }

    [HttpGet("search")]
    public async Task<IActionResult> Search([FromQuery] string? query, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var conversations = await chatService.GetConversationsAsync(userId.Value, cancellationToken);
        var conversationMatches = conversations
            .Where(c => string.IsNullOrWhiteSpace(query) || c.DisplayName.Contains(query, StringComparison.OrdinalIgnoreCase) || (c.LastMessage?.Contains(query, StringComparison.OrdinalIgnoreCase) ?? false))
            .ToList();

        var users = await userService.SearchUsersAsync(userId.Value, query, cancellationToken);
        var messages = await chatService.SearchMessagesAsync(userId.Value, query, cancellationToken);

        var result = new GlobalSearchResultDto
        {
            Conversations = conversationMatches,
            Users = users,
            Messages = messages
        };

        return Ok(result);
    }
}
