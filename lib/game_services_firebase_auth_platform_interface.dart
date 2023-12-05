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

  Future<bool> signInWithGameService({String? clientId}) {
    throw UnimplementedError(
        'signInWithGameService() has not been implemented.');
  }

  Future<bool> linkGameServicesCredentialsToCurrentUser(
      {String? clientId,
      bool forceSignInIfCredentialAlreadyUsed = false}) async {
    throw UnimplementedError(
        'linkGameServicesCredentialsToCurrentUser() has not been implemented.');
  }

  bool isUserLinkedToGameService() {
    throw UnimplementedError(
        'isUserLinkedToGameService() has not been implemented.');
  }
}
