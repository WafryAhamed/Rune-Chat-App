using Microsoft.EntityFrameworkCore;
using RuneChat.Api.Models;

namespace RuneChat.Api.Data;

public sealed class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<AppUser> Users => Set<AppUser>();
    public DbSet<Conversation> Conversations => Set<Conversation>();
    public DbSet<ConversationParticipant> ConversationParticipants => Set<ConversationParticipant>();
    public DbSet<Message> Messages => Set<Message>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<UserBlock> UserBlocks => Set<UserBlock>();
    public DbSet<PasswordResetToken> PasswordResetTokens => Set<PasswordResetToken>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AppUser>()
            .HasIndex(u => u.Email)
            .IsUnique();

        modelBuilder.Entity<AppUser>()
            .HasIndex(u => u.Username)
            .IsUnique();

        modelBuilder.Entity<AppUser>()
            .Property(u => u.Email)
            .HasConversion(v => v.ToLowerInvariant(), v => v);

        modelBuilder.Entity<ConversationParticipant>()
            .HasKey(cp => new { cp.ConversationId, cp.UserId });

        modelBuilder.Entity<ConversationParticipant>()
            .HasOne(cp => cp.Conversation)
            .WithMany(c => c.Participants)
            .HasForeignKey(cp => cp.ConversationId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<ConversationParticipant>()
            .HasOne(cp => cp.User)
            .WithMany(u => u.ConversationParticipants)
            .HasForeignKey(cp => cp.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Message>()
            .HasOne(m => m.Conversation)
            .WithMany(c => c.Messages)
            .HasForeignKey(m => m.ConversationId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Message>()
            .HasOne(m => m.Sender)
            .WithMany(u => u.SentMessages)
            .HasForeignKey(m => m.SenderId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Message>()
            .HasIndex(m => new { m.ConversationId, m.SentAt });

        modelBuilder.Entity<RefreshToken>()
            .HasIndex(rt => rt.Token)
            .IsUnique();

        modelBuilder.Entity<Notification>()
            .HasIndex(n => new { n.UserId, n.CreatedAt });

        modelBuilder.Entity<UserBlock>()
            .HasIndex(b => new { b.BlockerId, b.BlockedUserId })
            .IsUnique();

        modelBuilder.Entity<UserBlock>()
            .HasOne(b => b.Blocker)
            .WithMany(u => u.BlocksInitiated)
            .HasForeignKey(b => b.BlockerId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<UserBlock>()
            .HasOne(b => b.BlockedUser)
            .WithMany(u => u.BlocksReceived)
            .HasForeignKey(b => b.BlockedUserId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<PasswordResetToken>()
            .HasIndex(pr => pr.Token)
            .IsUnique();

        modelBuilder.Entity<PasswordResetToken>()
            .HasOne(pr => pr.User)
            .WithMany()
            .HasForeignKey(pr => pr.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        base.OnModelCreating(modelBuilder);
    }
}
