# Rune Chat App (Flutter + ASP.NET Core + SignalR + PostgreSQL)

Full-stack realtime mobile chat application with glassmorphism UI, JWT auth, and SignalR messaging.

---

## Architecture

- **Frontend**: Flutter (Dart), Riverpod, Dio, SignalR client
- **Backend**: ASP.NET Core Web API (.NET 10), SignalR, EF Core
- **Database**: PostgreSQL
- **Auth**: JWT + Refresh Tokens
- **Security**: BCrypt password hashing, JWT validation, HTTPS, rate limiting

---

## Workspace Structure

```text
Rune-Chat-App Public/
├─ .env
├─ RuneChat.slnx
├─ backend/
│  └─ RuneChat.Api/
│     ├─ Configuration/
│     ├─ Controllers/
│     ├─ DTOs/
│     ├─ Data/
│     ├─ Extensions/
│     ├─ Hubs/
│     ├─ Models/
│     ├─ Repositories/
│     ├─ Services/
│     ├─ Program.cs
│     ├─ appsettings.json
│     └─ RuneChat.Api.csproj
└─ frontend/
   └─ rune_chat_app/
      ├─ lib/
      │  ├─ core/
      │  ├─ features/
      │  ├─ models/
      │  ├─ screens/
      │  ├─ services/
      │  └─ widgets/
      ├─ pubspec.yaml
      └─ test/
```

---

## Environment

A root `.env` was created with your DB password (`2001`) and JWT placeholders.

Important values:

- `ConnectionStrings__DefaultConnection=Host=localhost;Port=5432;Database=runechat_db;Username=postgres;Password=2001`
- `Jwt__Key=CHANGE_ME_TO_A_LONG_RANDOM_SECRET_AT_LEAST_32_CHARS`

For production:

1. Replace JWT key with a strong secret.
2. Move secrets to secure secret management.
3. Use HTTPS certificates and restricted CORS origins.

---

## Backend Features Implemented

- Register/Login/Forgot Password/Reset Password
- Refresh token rotation + logout + session revocation
- User profile update and password change
- User blocking/unblocking
- Private conversation creation
- Message history retrieval + send + seen status
- Typing indicator events
- Presence (online/offline) tracking
- Notifications API
- Global search (users/conversations/messages)
- SignalR chat hub with JWT auth

### Main API Routes

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/forgot-password`
- `POST /api/auth/reset-password`
- `GET /api/users/me`
- `PUT /api/users/me`
- `GET /api/conversations`
- `GET /api/conversations/{id}/messages`
- `POST /api/conversations/send`
- `GET /api/notifications`
- `GET /api/conversations/search`
- SignalR hub: `/hubs/chat`

---

## Flutter Screens Implemented

- Splash
- Onboarding / Welcome
- Login
- Register
- Forgot Password
- Home / Chat List
- Chat Screen (typing, seen, mic glow, emoji icon, bubble layout)
- New Chat / User List
- Profile
- Edit Profile
- Settings
- Privacy & Security
- Notifications
- Media Preview
- File Upload
- Voice Message
- AI Chat
- Global Search
- Chat Info
- About
- Loading
- Error
- Empty State

---

## Run Locally

### 1) Start PostgreSQL

Create database:

- `runechat_db`

### 2) Run backend

```powershell
cd backend/RuneChat.Api
dotnet restore
dotnet run
```

Backend seeds default users on first startup:

- `alice@runechat.dev / Alice@123`
- `bob@runechat.dev / Bob@123`

### 3) Run Flutter app

```powershell
cd frontend/rune_chat_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5099 --dart-define=SIGNALR_HUB_URL=http://10.0.2.2:5099/hubs/chat
```

> `10.0.2.2` is for Android emulator. Use machine IP for physical devices.

---

## UI Design Notes

Implemented according to requested style:

- Palette: `#10242F`, `#40D2BA`, `#F7FFFF`
- Gradient layered background with blur circles
- Glassmorphism cards/inputs via `BackdropFilter`
- Neon glow buttons/mic accents
- Rounded corners and floating soft-shadowed components
- Poppins typography

---

## Production Hardening Checklist (Recommended Next)

- Add proper email provider for password reset delivery
- Add OAuth flow for Google/Apple social login
- Add media/file/voice upload backend storage pipeline
- Add push notifications (FCM/APNs)
- Add unit/integration tests for backend services/controllers
- Add CI/CD workflow and containerization
