part of 'http_service.dart';

class AuthenticationException implements Exception {
  String? message;

  AuthenticationException(String? _message) {
    message = _message;
  }
}

class SubscriptionException implements Exception {
  String? message;

  SubscriptionException(String? _message) {
    message = _message;
  }
}
// Connecting timed out [0ms]

class ConnectingTimedOut implements Exception {
  String? message;

  ConnectingTimedOut(String? _message) {
    message = _message;
  }
}
