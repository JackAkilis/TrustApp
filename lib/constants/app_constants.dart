/// App-wide constants
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // App Info
  static const String appName = 'Trust App';
  
  // Passcode
  static const int passcodeLength = 6;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Padding & Spacing
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double smallPadding = 8.0;
  
  // Border Radius
  static const double defaultBorderRadius = 12.0;
  static const double largeBorderRadius = 24.0;
  static const double smallBorderRadius = 8.0;
}
