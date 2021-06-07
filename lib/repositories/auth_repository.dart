import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_app/general_providers.dart';

import 'custom_exception.dart';

abstract class BaseAuthRepository {
  Stream<User?> get authStateChanges;

  Future<void> signInAnonymously();

  User? getCurrentUser();

  Future<void> signOut();
}

final authRepositoryProvider = Provider((ref) => AuthRepository(ref.read));

class AuthRepository implements BaseAuthRepository {
  final Reader _reader; //to read providers

  AuthRepository(this._reader);

  @override
  Stream<User?> get authStateChanges =>
      _reader(firebaseAuthProvider).authStateChanges();

  @override
  User? getCurrentUser() {
    try {
      return _reader(firebaseAuthProvider).currentUser;
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> signInAnonymously() async {
    try {
      await _reader(firebaseAuthProvider).signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _reader(firebaseAuthProvider).signOut();
      signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }
}

