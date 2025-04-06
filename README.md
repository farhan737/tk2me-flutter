# tk2me_flutter

A messaging app that communicates with Spring Boot backend.

## System Requirements

### Flutter and Dart
- Flutter SDK: Version 3.29.2 or higher
- Dart SDK: Version 3.7.2 or higher

### Java Development Kit (JDK)
- JDK Version: 17.x (Recommended: Temurin/AdoptOpenJDK 17.0.14+)
- **Note**: Java 21 requires Gradle 8.5+, while this project is configured for Gradle 8.0 with Java 17

### Android Development
- Android SDK: Version 35.0.1
- Android Gradle Plugin (AGP): Version 8.1.0
- Gradle: Version 8.0
- Kotlin: Version 1.9.22
- Build Tools: Version 33.0.1

### IDE Support
- Android Studio 2024.3 or newer
- Visual Studio Code with Flutter extension

## Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  http: ^1.3.0
  provider: ^6.0.5
  shared_preferences: ^2.5.3
  flutter_secure_storage: ^8.1.0
  intl: ^0.18.1
```

## Setup Instructions

### 1. Flutter Setup
Make sure Flutter is properly installed and configured:
```
flutter doctor -v
```

### 2. Java Configuration
Configure Flutter to use Java 17:
```
flutter config --jdk-dir="C:\path\to\jdk-17"
```

### 3. Android SDK Configuration
Accept all Android licenses:
```
flutter doctor --android-licenses
```

### 4. Building the App
- For development: `flutter run`
- For Android APK: `flutter build apk`
- For Web: `flutter run -d chrome`

### 5. Known Issues and Workarounds

#### Android Build Issues
If you encounter R8 optimization errors, check the ProGuard rules in `android/app/proguard-rules.pro`.

#### Gradle/Java Compatibility
- If using Java 21: Update Gradle to 8.5+ in `android/gradle/wrapper/gradle-wrapper.properties`
- If using Java 17: Current Gradle 8.0 configuration is compatible

#### Multiple settings.gradle Files
The project contains both `settings.gradle` and `settings.gradle.kts`. The Kotlin DSL version (`settings.gradle.kts`) is ignored.

## Troubleshooting

### Common Error Messages

1. **"Minimum supported Gradle version is 8.0"**
   - Solution: Update Gradle version in `android/gradle/wrapper/gradle-wrapper.properties`

2. **"Using compileSdk 35 requires Android Gradle Plugin (AGP) 8.1.0 or higher"**
   - Solution: Update AGP version in `android/settings.gradle`

3. **"Missing classes detected while running R8"**
   - Solution: Add appropriate ProGuard rules or disable R8 full mode

4. **"Resource shrinker cannot be used for libraries"**
   - Solution: Set `shrinkResources false` in the app's build.gradle file

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Gradle-Java Compatibility Matrix](https://docs.gradle.org/current/userguide/compatibility.html#java)
