using RuneChat.Api.Models;

namespace RuneChat.Api.Repositories.Interfaces;

public interface INotificationRepository
{
    Task AddAsync(Notification notification, CancellationToken cancellationToken = default);
    Task<Notification?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<List<Notification>> GetUserNotificationsAsync(Guid userId, int take = 50, CancellationToken cancellationToken = default);
    void Update(Notification notification);
    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}
