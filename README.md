# 🎮 Game Services Firebase Auth

This plugin make some FirebaseAuth features available with GameCenter on iOS and PlayGames on Android

## ⛏ Getting started

### 🤖 Android

• Configure your app for Firebase [(🔗 Doc link)](https://firebase.flutter.dev/docs/overview)

• Configure you app for Play Games [(🔗 Doc link)](https://developers.google.com/games/services/console/enabling)

• Enjoy 🙌


### 🍏 iOS
• Configure your app for Firebase [(🔗 Doc link)](https://firebase.flutter.dev/docs/overview)

• Configure you app for GameCenter [(🔗 Doc link)](https://developer.apple.com/documentation/gamekit/enabling_and_configuring_game_center)

• Enjoy 🙌


## 📋 Methods available

### signInWithGameService

```dart
/// Try to sign in with native Game Service (Play Games on Android and GameCenter on iOS)
/// Return `true` if success
/// [clientId] is only for Android if you want to provide a clientId other than the main one in you google-services.json
Future<bool> signInWithGameService({String? clientId})
```

### linkGameServicesCredentialsToCurrentUser

```dart
 /// Try to sign link current user with native Game Service (Play Games on Android and GameCenter on iOS)
  /// Return `true` if success
  /// [clientId] is only for Android if you want to provide a clientId other than the main one in you google-services.json
  /// [forceSignInIfCredentialAlreadyUsed] make user force sign in with game services link failed because of ERROR_CREDENTIAL_ALREADY_IN_USE
  static Future<bool> linkGameServicesCredentialsToCurrentUser({String? clientId, bool forceSignInIfCredentialAlreadyUsed = false})
```





