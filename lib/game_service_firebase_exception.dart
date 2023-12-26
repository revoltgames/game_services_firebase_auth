enum GameServiceFirebaseAuthError {
  /// An unknown error.
  unknown,

  /// This error can happen when trying to link accounts. The Game Service
  /// credential (obtained via Game Center for example) is already linked to
  /// another Firebase account. Try calling sign-in instead of link.
  game_service_credential_already_in_use,

  /// The user has not configured the native Game Service provider correctly.
  /// This might be because they are not signed in or refused to sign in. This
  /// is an error you should ask the app user to correct.
  device_not_signed_into_game_service,

  /// You called a function that expects to find a signed in Firebase user but
  /// there wasn't one.
  firebase_user_signed_out,
}

class GameServiceFirebaseAuthException implements Exception {
  final GameServiceFirebaseAuthError code;
  final String? message;
  final String? details;
  final String? stackTrace;

  GameServiceFirebaseAuthException({
    this.code = GameServiceFirebaseAuthError.unknown,
    this.message,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() => '[$code] $message: $details';
}
