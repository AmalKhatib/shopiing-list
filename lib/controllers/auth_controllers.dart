import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_app/repositories/auth_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, User?>(
    (ref) => AuthController(ref.read));

class AuthController extends StateNotifier<User?> {
  final Reader _reader;
  StreamSubscription<User?>? _authStateChangesSubscription;

  AuthController(this._reader) : super(null) {
    _authStateChangesSubscription?.cancel();
    _authStateChangesSubscription = _reader(authRepositoryProvider)
        .authStateChanges
        .listen((user) => state = user);
  }

  @override
  void dispose() {
    _authStateChangesSubscription?.cancel();
    super.dispose();
  }

  appStarted() async {
    final user = _reader(authRepositoryProvider).getCurrentUser();
    if (user == null){
      print("null");
      await _reader(authRepositoryProvider).signInAnonymously();
    }else
      print("not null");
  }

  signOut() async {
    await _reader(authRepositoryProvider).signOut();
  }
}
