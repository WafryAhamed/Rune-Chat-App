using RuneChat.Api.DTOs.Notifications;

namespace RuneChat.Api.Services.Interfaces;

public interface INotificationService
{
    Task<IReadOnlyList<NotificationDto>> GetForUserAsync(Guid userId, CancellationToken cancellationToken = default);
    Task AddAsync(Guid userId, string title, string body, CancellationToken cancellationToken = default);
    Task<bool> MarkReadAsync(Guid userId, Guid notificationId, CancellationToken cancellationToken = default);
}
