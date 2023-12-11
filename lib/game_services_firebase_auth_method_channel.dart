import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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
      final dynamic result = await _withPopupNotShownTimeout(methodChannel
          .invokeMethod('sign_in_with_game_service',
              {'client_id': androidOAuthClientId}));
      if (result is bool) {
        return result;
      }
      return false;
    } on GameServiceFirebaseAuthException catch (error) {
      throw error;
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
    } on GameServiceFirebaseAuthException catch (error) {
      throw error;
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

  /// A helper method that times out the given future if no pop-up (view
  /// controller) is shown within the given timeframe.
  Future<dynamic> _withPopupNotShownTimeout(Future<dynamic> invocation,
      {Duration timeLimit = const Duration(seconds: 8)}) {
    final Completer<bool> popUpShownCompleter = Completer();
    AppLifecycleListener appLifecycleListener =
        AppLifecycleListener(onInactive: () {
      if (!popUpShownCompleter.isCompleted) popUpShownCompleter.complete(true);
    });
    Future.delayed(timeLimit).then((_) {
      if (!popUpShownCompleter.isCompleted) popUpShownCompleter.complete(false);
    });
    Future<void> timeout = popUpShownCompleter.future.then((popUpShown) {
      appLifecycleListener.dispose();
      if (!popUpShown)
        throw GameServiceFirebaseAuthException(
            code: GameServiceFirebaseAuthError
                .device_not_signed_into_game_service,
            message: 'User has disabled Game Services.',
            details:
                'Platform has failed to display a login popup within the allotted timeframe. '
                'This check is to prevent a bug with Game Center where the iOS SDK starts '
                'silently ignoring login calls if the user cancels the popup 3+ times. '
                'See https://stackoverflow.com/questions/18927723.');
    });
    return Future.any([invocation, timeout]);
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
