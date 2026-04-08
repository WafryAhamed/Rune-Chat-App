class AppConstants {
  const AppConstants._();

  static const appName = 'Lanka Chat';

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5251',
  );

  static const signalRHubUrl = String.fromEnvironment(
    'SIGNALR_HUB_URL',
    defaultValue: 'http://localhost:5251/hubs/chat',
  );

  static const glassOpacity = 0.08;
  static const glassBorderOpacity = 0.10;
  static const blurSigma = 20.0;
  static const borderRadius = 24.0;
}
