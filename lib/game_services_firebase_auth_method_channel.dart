import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:game_services_firebase_auth/game_service_firebase_exception.dart';

import 'game_services_firebase_auth_platform_interface.dart';

/// An implementation of [GameServicesFirebaseAuthPlatform] that uses method channels.
class MethodChannelGameServicesFirebaseAuth
    extends GameServicesFirebaseAuthPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('game_services_firebase_auth');

  /// Try to sign in with native Game Service (Play Games on Android and GameCenter on iOS)
  /// Return `true` if success
  /// [clientId] is only for Android if you want to provide a clientId other than the main one in you google-services.json
  @override
  Future<bool> signInWithGameService({String? clientId}) async {
    try {
      final dynamic result = await methodChannel
          .invokeMethod('sign_in_with_game_service', {'client_id': clientId});

      if (result is bool) {
        return result;
      } else {
        return false;
      }
    } on PlatformException catch (error) {
      String code = 'unknown';

      switch (error.code) {
        case 'ERROR_CREDENTIAL_ALREADY_IN_USE':
          code = 'credential_already_in_use';
          break;
        case 'get_gamecenter_credentials_failed':
        case 'no_player_detected':
        case '12501':
          code = 'game_service_badly_configured_user_side';
          break;
      }
      throw GameServiceFirebaseAuthException(
          code: code, message: error.message, stackTrace: error.stacktrace);
    } catch (error) {
      throw GameServiceFirebaseAuthException(message: error.toString());
    }
  }

  /// Try to sign link current user with native Game Service (Play Games on Android and GameCenter on iOS)
  /// Return `true` if success
  /// [clientId] is only for Android if you want to provide a clientId other than the main one in you google-services.json
  /// [forceSignInIfCredentialAlreadyUsed] make user force sign in with game services link failed because of ERROR_CREDENTIAL_ALREADY_IN_USE
  @override
  Future<bool> linkGameServicesCredentialsToCurrentUser(
      {String? clientId,
      bool forceSignInIfCredentialAlreadyUsed = false}) async {
    try {
      final dynamic result = await methodChannel
          .invokeMethod('link_game_services_credentials_to_current_user', {
        'client_id': clientId,
        'force_sign_in_credential_already_used':
            forceSignInIfCredentialAlreadyUsed,
      });

      if (result is bool) {
        return result;
      } else {
        return false;
      }
    } on PlatformException catch (error) {
      String code = 'unknown';

      switch (error.code) {
        case 'ERROR_CREDENTIAL_ALREADY_IN_USE':
          code = 'credential_already_in_use';
          break;
        case 'get_gamecenter_credentials_failed':
        case 'no_player_detected':
        case '12501':
          code = 'game_service_badly_configured_user_side';
          break;
      }
      throw GameServiceFirebaseAuthException(
          code: code, message: error.message, stackTrace: error.stacktrace);
    } catch (error) {
      throw GameServiceFirebaseAuthException(message: error.toString());
    }
  }

  /// Test if a user is already linked to a game service
  /// Advised to be call before linkGameServicesCredentialsToCurrentUser()
  @override
  bool isUserLinkedToGameService() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Firebase user is null');
    }

    final isLinked = user.providerData
        .map((userInfo) => userInfo.providerId)
        .contains(Platform.isIOS ? 'gc.apple.com' : 'playgames.google.com');

    return isLinked;
  }
}
