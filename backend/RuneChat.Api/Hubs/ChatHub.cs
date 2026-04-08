using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using RuneChat.Api.DTOs.Chat;
using RuneChat.Api.Extensions;
using RuneChat.Api.Services.Interfaces;

namespace RuneChat.Api.Hubs;

[Authorize]
public sealed class ChatHub(
    IChatService chatService,
    INotificationService notificationService,
    IPresenceService presenceService,
    ILogger<ChatHub> logger) : Hub
{
    public override async Task OnConnectedAsync()
    {
        var userId = Context.User?.GetUserId();
        if (userId is null)
        {
            await base.OnConnectedAsync();
            return;
        }

        logger.LogInformation("User {UserId} connected with connection {ConnectionId}", userId, Context.ConnectionId);

        var becameOnline = presenceService.Connect(userId.Value, Context.ConnectionId);
        if (becameOnline)
        {
            await Clients.All.SendAsync("PresenceChanged", userId, true);
        }

        await Clients.Caller.SendAsync("OnlineUsers", presenceService.GetOnlineUsers());
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = Context.User?.GetUserId();
        if (userId is not null)
        {
            logger.LogInformation("User {UserId} disconnected from connection {ConnectionId}", userId, Context.ConnectionId);
            var becameOffline = presenceService.Disconnect(userId.Value, Context.ConnectionId);
            if (becameOffline)
            {
                await Clients.All.SendAsync("PresenceChanged", userId, false);
            }
        }

        if (exception is not null)
        {
            logger.LogWarning(exception, "Connection {ConnectionId} disconnected with exception", Context.ConnectionId);
        }

        await base.OnDisconnectedAsync(exception);
    }

    public async Task JoinConversation(Guid conversationId)
    {
        var userId = Context.User?.GetUserId();
        if (userId is null)
        {
            return;
        }

        var canAccess = await chatService.CanAccessConversationAsync(userId.Value, conversationId);
        if (!canAccess)
        {
            return;
        }

        await Groups.AddToGroupAsync(Context.ConnectionId, conversationId.ToString());
    }

    public async Task LeaveConversation(Guid conversationId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, conversationId.ToString());
    }

    public async Task SendMessage(SendMessageRequest request)
    {
        var userId = Context.User?.GetUserId();
        if (userId is null)
        {
            return;
        }

        var message = await chatService.SendMessageAsync(userId.Value, request);
        if (message is null)
        {
            return;
        }

        var groupName = request.ConversationId.ToString();
        await Clients.Group(groupName).SendAsync("ReceiveMessage", message);

        var participants = await chatService.GetConversationParticipantIdsAsync(request.ConversationId);
        foreach (var participantId in participants.Where(id => id != userId))
        {
            foreach (var connectionId in presenceService.GetConnections(participantId))
            {
                await Clients.Client(connectionId).SendAsync("ReceiveMessage", message);
            }

            await notificationService.AddAsync(participantId, "New message", message.Content);
        }
    }

    public async Task Typing(Guid conversationId, bool isTyping)
    {
        var userId = Context.User?.GetUserId();
        if (userId is null)
        {
            return;
        }

        var canAccess = await chatService.CanAccessConversationAsync(userId.Value, conversationId);
        if (!canAccess)
        {
            return;
        }

        var payload = new TypingEventDto
        {
            ConversationId = conversationId,
            UserId = userId.Value,
            IsTyping = isTyping
        };

        await Clients.OthersInGroup(conversationId.ToString()).SendAsync("Typing", payload);
    }

    public async Task MarkSeen(Guid messageId)
    {
        var userId = Context.User?.GetUserId();
        if (userId is null)
        {
            return;
        }

        var seen = await chatService.MarkSeenAsync(userId.Value, messageId);
        if (seen is null)
        {
            return;
        }

        await Clients.Group(seen.ConversationId.ToString()).SendAsync("MessageSeen", seen);
    }
}
