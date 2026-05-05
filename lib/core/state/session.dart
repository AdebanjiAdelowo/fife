import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter/foundation.dart';

import '../../models/user_profile.dart';
import '../storage/local_storage.dart';

/// Lightweight ChangeNotifier-based session. Holds the currently signed-in
/// user (if any) and provides sign-up / sign-in / sign-out helpers backed by
/// local storage. Passwords are hashed with sha256 before persistence —
/// fine for an offline test build, replace with a proper KMS when we go live.
class Session extends ChangeNotifier {
  Session(this._storage);

  final LocalStorage _storage;

  UserProfile? _user;
  UserProfile? get user => _user;
  bool get isSignedIn => _user != null;

  Future<void> bootstrap() async {
    _user = await _storage.currentUser();
    notifyListeners();
  }

  Future<UserProfile> register({
    required String email,
    required String password,
    String? programCode,
  }) async {
    final existing = await _storage.findUserByEmail(email);
    if (existing != null) {
      throw const SessionException('That email is already a FIFER. Try signing in.');
    }
    final user = UserProfile(
      id: _generateId(),
      email: email.trim(),
      passwordHash: _hash(password),
      programCode: programCode?.trim().isEmpty ?? true ? null : programCode!.trim(),
    );
    await _storage.saveUser(user);
    await _storage.setCurrentUser(user.id);
    _user = user;
    notifyListeners();
    return user;
  }

  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final user = await _storage.findUserByEmail(email);
    if (user == null) {
      throw const SessionException('No FIFE account matches that email.');
    }
    if (user.passwordHash != _hash(password)) {
      throw const SessionException('Wrong password — try again.');
    }
    await _storage.setCurrentUser(user.id);
    _user = user;
    notifyListeners();
    return user;
  }

  Future<void> signOut() async {
    await _storage.clearCurrentUser();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    await _storage.saveUser(updated);
    _user = updated;
    notifyListeners();
  }

  static String _generateId() {
    final rng = math.Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static String _hash(String input) {
    return sha256.convert(utf8.encode('fife::$input')).toString();
  }
}

class SessionException implements Exception {
  const SessionException(this.message);
  final String message;
  @override
  String toString() => message;
}
