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
    final dynamic result = await _channel.invokeMethod('signInWithGameService', {'client_id': clientId});

    if (result is bool) {
      return result;
    } else {
      return false;
    }
  }

  /// Try to sign link current user with native Game Service (Play Games on Android and GameCenter on iOS)
  /// Return `true` if success
  /// [clientId] is only for Android if you want to provide a clientId other than the main one in you google-services.json
  static Future<bool> linkGameServicesCredentialsToCurrentUser({String? clientId}) async {
    final dynamic result =
        await _channel.invokeMethod('linkGameServicesCredentialsToCurrentUser', {'client_id': clientId});

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
