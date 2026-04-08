import '../../models/user_model.dart';

class AuthState {
  const AuthState({
    required this.isInitialized,
    required this.isLoading,
    this.accessToken,
    this.refreshToken,
    this.user,
    this.error,
  });

  factory AuthState.initial() {
    return const AuthState(isInitialized: false, isLoading: false);
  }

  final bool isInitialized;
  final bool isLoading;
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;
  final String? error;

  bool get isAuthenticated => accessToken != null && user != null;

  AuthState copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? accessToken,
    String? refreshToken,
    UserModel? user,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
