import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class GameServicesFirebaseAuth {
  static const MethodChannel _channel = const MethodChannel('game_services_firebase_auth');

  /// Try to sign in with native Game Service (Play Games on Android and GameCenter on iOS)
  /// Return `true` if success
  /// [clientId] is only for Android if you want to provide a clientId other than the main one in you google-services.json
  static Future<bool> signInWithGameService({String? clientId}) async {
    final dynamic result = await _channel.invokeMethod('sign_in_with_game_service', {'client_id': clientId});

    if (result is bool) {
      return result;
    } else {
      return false;
    }
  }

  /// Try to sign link current user with native Game Service (Play Games on Android and GameCenter on iOS)
  /// Return `true` if success
  /// [clientId] is only for Android if you want to provide a clientId other than the main one in you google-services.json
  /// [forceSignInIfCredentialAlreadyUsed] make user force sign in with game services link failed because of ERROR_CREDENTIAL_ALREADY_IN_USE
  static Future<bool> linkGameServicesCredentialsToCurrentUser(
      {String? clientId, bool forceSignInIfCredentialAlreadyUsed = false}) async {
    final dynamic result = await _channel.invokeMethod('link_game_services_credentials_to_current_user', {
      'client_id': clientId,
      'force_sign_in_credential_already_used': forceSignInIfCredentialAlreadyUsed,
    });

    if (result is bool) {
      return result;
    } else {
      return false;
    }
  }

  /// Test if a user is already linked to a game service
  /// Advised to be call before linkGameServicesCredentialsToCurrentUser()
  static bool isUserLinkedToGameService() {
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
