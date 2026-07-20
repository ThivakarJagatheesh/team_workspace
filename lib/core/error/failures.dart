import 'package:equatable/equatable.dart';

/// Base type for all recoverable errors surfaced to the domain/presentation
/// layers. Repositories return `Either<Failure, T>` so the UI never handles a
/// raw exception.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// A remote call failed (non-2xx, malformed body, etc.).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}

/// No / unreliable network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// Local cache read/write failed or was empty.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No cached data available.']);
}

/// Authentication-specific failure (invalid credentials, weak password, …).
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

/// Client-side validation failure.
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input.']);
}
