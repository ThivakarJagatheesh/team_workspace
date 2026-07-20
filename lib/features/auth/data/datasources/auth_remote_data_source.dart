import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Wraps FirebaseAuth. Translates FirebaseAuthException into our [AuthException]
/// with a friendly message, so upper layers stay Firebase-agnostic.
abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({required String email, required String password});
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
  UserModel? currentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._auth);

  final FirebaseAuth _auth;

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebase(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapCode(e.code));
    } catch (_) {
      throw AuthException();
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebase(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapCode(e.code));
    } catch (_) {
      throw AuthException();
    }
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  UserModel? currentUser() {
    final user = _auth.currentUser;
    return user == null ? null : UserModel.fromFirebase(user);
  }

  /// Firebase error code → human message.
  String _mapCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
