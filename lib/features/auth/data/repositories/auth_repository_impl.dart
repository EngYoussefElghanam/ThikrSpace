import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:thikrspace_beta/core/storage/hive_service.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  AuthUser _mapFirebaseUser(fb_auth.User user) {
    return AuthUser(
        id: user.uid, email: user.email ?? '', name: user.displayName ?? '');
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _dataSource.authStateChanges.map((fbUser) {
      if (fbUser == null) return null;
      return _mapFirebaseUser(fbUser);
    });
  }

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    final fbUser = await _dataSource.signIn(email, password);
    return _mapFirebaseUser(fbUser);
  }

  @override
  Future<AuthUser> signUpWithEmail(String email, String password) async {
    final fbUser = await _dataSource.signUp(email, password);
    return _mapFirebaseUser(fbUser);
  }

  @override
  Future<void> signOut() async {
    await HiveService.instance.clearUserData();
    await _dataSource.signOut();
  }
}
