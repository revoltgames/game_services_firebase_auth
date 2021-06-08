class GameServiceFirebaseAuthException implements Exception {
  GameServiceFirebaseAuthException({this.code = 'unknown', this.message, this.stackTrace});

  final String code;
  final String? message;
  final String? stackTrace;

  @override
  String toString() => '[$code] $message';
}
