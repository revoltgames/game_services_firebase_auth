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

  @override
  Future<bool> signInWithGameService({String? androidOAuthClientId}) async {
    try {
      final dynamic result = await methodChannel.invokeMethod(
          'sign_in_with_game_service', {'client_id': androidOAuthClientId});
      if (result is bool) {
        return result;
      }
      return false;
    } on PlatformException catch (error) {
      throw GameServiceFirebaseAuthException(
          code: error.toAuthError(),
          message: error.message,
          details: error.details,
          stackTrace: error.stacktrace);
    } catch (error) {
      throw GameServiceFirebaseAuthException(message: error.toString());
    }
  }

  @override
  bool isUserLinkedToGameService() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw GameServiceFirebaseAuthException(
          code: GameServiceFirebaseAuthError.firebase_user_signed_out,
          message: 'Firebase user is null.');
    }

    final isLinked = user.providerData
        .map((userInfo) => userInfo.providerId)
        .contains(Platform.isIOS ? 'gc.apple.com' : 'playgames.google.com');

    return isLinked;
  }

  @override
  Future<bool> linkGameServicesCredentialsToCurrentUser(
      {String? androidOAuthClientId,
      bool switchFirebaseUsersIfNeeded = false}) async {
    try {
      final dynamic result = await methodChannel
          .invokeMethod('link_game_services_credentials_to_current_user', {
        'client_id': androidOAuthClientId,
        'force_sign_in_credential_already_used': switchFirebaseUsersIfNeeded,
      });
      if (result is bool) {
        return result;
      }
      return false;
    } on PlatformException catch (error) {
      throw GameServiceFirebaseAuthException(
          code: error.toAuthError(),
          message: error.message,
          details: error.details,
          stackTrace: error.stacktrace);
    } catch (error) {
      throw GameServiceFirebaseAuthException(message: error.toString());
    }
  }
}

extension PlatformErrorCodeToAuthError on PlatformException {
  GameServiceFirebaseAuthError toAuthError() {
    switch (code) {
      case 'ERROR_CREDENTIAL_ALREADY_IN_USE':
        return GameServiceFirebaseAuthError
            .game_service_credential_already_in_use;
      case 'get_gamecenter_credentials_failed':
      case 'no_player_detected':
      case '12501':
        return GameServiceFirebaseAuthError.device_not_signed_into_game_service;
      default:
        return GameServiceFirebaseAuthError.unknown;
    }
  }
}
