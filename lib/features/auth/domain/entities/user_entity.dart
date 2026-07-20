import 'package:equatable/equatable.dart';

/// Authenticated user — the domain's view of an account (no Firebase types leak
/// into domain/presentation).
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;

  @override
  List<Object?> get props => [id, email, displayName];
}
