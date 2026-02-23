import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thikrspace_beta/features/auth/domain/entities/auth_user.dart';
import 'package:thikrspace_beta/features/auth/domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<AuthUser?>? _authSubscription;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _monitorAuthState();
  }

  void _monitorAuthState() {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithEmail(email, password);
      // We don't need to emit Authenticated here because the stream listener will catch it.
    } catch (e) {
      emit(AuthError(_mapErrorMessage(e)));
      emit(AuthUnauthenticated()); // Reset state so they can try again
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
    } catch (e) {
      emit(AuthError("Failed to sign out."));
    }
  }

  String _mapErrorMessage(dynamic error) {
    // A simple mapper for Day 2. You can expand this later.
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('user-not-found') ||
        errorString.contains('wrong-password') ||
        errorString.contains('invalid-credential')) {
      return 'Invalid email or password.';
    } else if (errorString.contains('network-request-failed')) {
      return 'Network error. Please check your connection.';
    }
    return 'An error occurred during sign in.';
  }

  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(email, password);
      // DO NOT emit AuthAuthenticated here!
      // The _monitorAuthState stream will catch the login automatically.
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated()); // Reset state so they can try again
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();

      if (user == null) {
        // EDGE CASE: User cancelled. Reset quietly.
        emit(AuthInitial());
        return;
      }

      // DO NOT emit AuthAuthenticated here!
      // The stream handles it.
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.code));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Google sign in failed. Please try again.'));
      emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
