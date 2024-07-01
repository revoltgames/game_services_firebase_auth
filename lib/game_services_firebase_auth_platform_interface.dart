import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'game_services_firebase_auth_method_channel.dart';

abstract class GameServicesFirebaseAuthPlatform extends PlatformInterface {
  /// Constructs a GameServicesFirebaseAuthPlatform.
  GameServicesFirebaseAuthPlatform() : super(token: _token);

  static final Object _token = Object();

  static GameServicesFirebaseAuthPlatform _instance =
      MethodChannelGameServicesFirebaseAuth();

  /// The default instance of [GameServicesFirebaseAuthPlatform] to use.
  ///
  /// Defaults to [MethodChannelGameServicesFirebaseAuth].
  static GameServicesFirebaseAuthPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GameServicesFirebaseAuthPlatform] when
  /// they register themselves.
  static set instance(GameServicesFirebaseAuthPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Try to sign in with native Game Service (Play Games on Android and Game
  /// Center on iOS).
  ///
  /// Return `true` if success, `false` upon failure.
  ///
  /// [androidOAuthClientId] is only for Android if you want to provide a
  /// client ID other than the main one in your `google-services.json`.
  ///
  /// Throws an [GameServiceFirebaseAuthException] when there is a problem.
  Future<bool> signInWithGameService({String? androidOAuthClientId}) {
    throw UnimplementedError(
        'signInWithGameService() has not been implemented.');
  }

  /// Test if the currently logged in Firebase user is already linked to the
  /// native Game Service account.
  ///
  /// Advised to be call before [linkGameServicesCredentialsToCurrentUser()].
  ///
  /// Throws an [GameServiceFirebaseAuthException] when there is a problem.
  bool isUserLinkedToGameService() {
    throw UnimplementedError(
        'isUserLinkedToGameService() has not been implemented.');
  }

  /// Try to link the currently logged in Firebase user with native Game Service
  /// (Play Games on Android and GameCenter on iOS) account.
  ///
  /// Return `true` if success, `false` upon failure.
  ///
  /// [androidOAuthClientId] is only for Android if you want to provide a
  /// client ID other than the main one in your `google-services.json`.
  ///
  /// If the Game Service account is already linked to another Firebase user
  /// this function will throw [GameServiceFirebaseAuthException] with `code`
  /// [GameServiceFirebaseAuthError.game_service_credential_already_in_use]. In
  /// this scenario if you would rather prefer that the Firebase user is swapepd
  /// to the one already linked to the Game Service account set
  /// [switchFirebaseUsersIfNeeded] to `true`.
  ///
  /// Throws an [GameServiceFirebaseAuthException] when there is a problem.
  Future<bool> linkGameServicesCredentialsToCurrentUser(
      {String? androidOAuthClientId,
      bool switchFirebaseUsersIfNeeded = false}) async {
    throw UnimplementedError(
        'linkGameServicesCredentialsToCurrentUser() has not been implemented.');
  }
}
