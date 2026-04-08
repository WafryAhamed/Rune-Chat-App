import 'package:flutter/material.dart';

import '../models/conversation_model.dart';
import '../screens/about_app_screen.dart';
import '../screens/ai_chat_screen.dart';
import '../screens/chat_info_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/empty_state_screen.dart';
import '../screens/error_screen.dart';
import '../screens/file_upload_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/global_search_screen.dart';
import '../screens/home_chat_list_screen.dart';
import '../screens/loading_screen.dart';
import '../screens/login_screen.dart';
import '../screens/media_preview_screen.dart';
import '../screens/new_chat_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/privacy_security_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/voice_message_screen.dart';
import 'constants/route_names.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _material(const SplashScreen(), settings);
      case RouteNames.onboarding:
        return _material(const OnboardingScreen(), settings);
      case RouteNames.login:
        return _material(const LoginScreen(), settings);
      case RouteNames.register:
        return _material(const RegisterScreen(), settings);
      case RouteNames.forgotPassword:
        return _material(const ForgotPasswordScreen(), settings);
      case RouteNames.home:
        return _material(const HomeChatListScreen(), settings);
      case RouteNames.chat:
        final conversation = settings.arguments as ConversationModel?;
        if (conversation == null) {
          return _material(
            const ErrorScreen(
              args: ErrorScreenArgs(
                message: 'Conversation was not provided.',
                retryRoute: RouteNames.home,
              ),
            ),
            settings,
          );
        }
        return _material(ChatScreen(conversation: conversation), settings);
      case RouteNames.newChat:
        return _material(const NewChatScreen(), settings);
      case RouteNames.profile:
        return _material(const ProfileScreen(), settings);
      case RouteNames.editProfile:
        return _material(const EditProfileScreen(), settings);
      case RouteNames.settings:
        return _material(const SettingsScreen(), settings);
      case RouteNames.privacy:
        return _material(const PrivacySecurityScreen(), settings);
      case RouteNames.notifications:
        return _material(const NotificationsScreen(), settings);
      case RouteNames.mediaPreview:
        return _material(const MediaPreviewScreen(), settings);
      case RouteNames.fileUpload:
        return _material(const FileUploadScreen(), settings);
      case RouteNames.voiceMessage:
        return _material(const VoiceMessageScreen(), settings);
      case RouteNames.aiChat:
        return _material(const AiChatScreen(), settings);
      case RouteNames.globalSearch:
        return _material(const GlobalSearchScreen(), settings);
      case RouteNames.chatInfo:
        final conversation = settings.arguments as ConversationModel?;
        if (conversation == null) {
          return _material(
            const ErrorScreen(
              args: ErrorScreenArgs(
                message: 'Chat info requires a conversation.',
                retryRoute: RouteNames.home,
              ),
            ),
            settings,
          );
        }

        return _material(ChatInfoScreen(conversation: conversation), settings);
      case RouteNames.about:
        return _material(const AboutAppScreen(), settings);
      case RouteNames.loading:
        return _material(const LoadingScreen(), settings);
      case RouteNames.error:
        final args = settings.arguments as ErrorScreenArgs?;
        return _material(ErrorScreen(args: args), settings);
      case RouteNames.empty:
        return _material(const EmptyStateScreen(), settings);
      default:
        return _material(
          const ErrorScreen(
            args: ErrorScreenArgs(
              message: 'Route not found.',
              retryRoute: RouteNames.home,
            ),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _material(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}
