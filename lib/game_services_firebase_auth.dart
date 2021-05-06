import 'dart:async';

import 'package:flutter/services.dart';

class GameServicesFirebaseAuth {
  static const MethodChannel _channel = const MethodChannel('game_services_firebase_auth');

  // Try to sign in with native Game Service (Play Games on Android and GameCenter on iOS)
  // Return true if success
  static Future<bool> signInWithGameService() async {
    final dynamic result = await _channel.invokeMethod('signInWithGameService');

    if (result is bool) {
      return result;
    } else {
      return false;
    }
  }
}
