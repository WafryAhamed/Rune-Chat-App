using RuneChat.Api.DTOs.Notifications;
using RuneChat.Api.Models;
using RuneChat.Api.Repositories.Interfaces;
using RuneChat.Api.Services.Interfaces;

namespace RuneChat.Api.Services.Implementations;

public sealed class NotificationService(INotificationRepository notificationRepository) : INotificationService
{
    public async Task<IReadOnlyList<NotificationDto>> GetForUserAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var items = await notificationRepository.GetUserNotificationsAsync(userId, cancellationToken: cancellationToken);
        return items.Select(ToDto).ToList();
    }

    public async Task AddAsync(Guid userId, string title, string body, CancellationToken cancellationToken = default)
    {
        var entity = new Notification
        {
            UserId = userId,
            Title = title,
            Body = body,
            IsRead = false,
            CreatedAt = DateTime.UtcNow
        };

        await notificationRepository.AddAsync(entity, cancellationToken);
        await notificationRepository.SaveChangesAsync(cancellationToken);
    }

    public async Task<bool> MarkReadAsync(Guid userId, Guid notificationId, CancellationToken cancellationToken = default)
    {
        var item = await notificationRepository.GetByIdAsync(notificationId, cancellationToken);
        if (item is null || item.UserId != userId)
        {
            return false;
        }

        item.IsRead = true;
        notificationRepository.Update(item);
        await notificationRepository.SaveChangesAsync(cancellationToken);
        return true;
    }

    private static NotificationDto ToDto(Notification item)
    {
        return new NotificationDto
        {
            Id = item.Id,
            Title = item.Title,
            Body = item.Body,
            IsRead = item.IsRead,
            CreatedAt = item.CreatedAt
        };
    }
}
