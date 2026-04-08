using Microsoft.EntityFrameworkCore;
using RuneChat.Api.Data;
using RuneChat.Api.Models;
using RuneChat.Api.Repositories.Interfaces;

namespace RuneChat.Api.Repositories.Implementations;

public sealed class NotificationRepository(AppDbContext dbContext) : INotificationRepository
{
    public Task AddAsync(Notification notification, CancellationToken cancellationToken = default)
    {
        return dbContext.Notifications.AddAsync(notification, cancellationToken).AsTask();
    }

    public Task<Notification?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return dbContext.Notifications.FirstOrDefaultAsync(n => n.Id == id, cancellationToken);
    }

    public Task<List<Notification>> GetUserNotificationsAsync(Guid userId, int take = 50, CancellationToken cancellationToken = default)
    {
        return dbContext.Notifications
            .AsNoTracking()
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .Take(Math.Clamp(take, 1, 200))
            .ToListAsync(cancellationToken);
    }

    public void Update(Notification notification)
    {
        dbContext.Notifications.Update(notification);
    }

    public Task SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return dbContext.SaveChangesAsync(cancellationToken);
    }
}
