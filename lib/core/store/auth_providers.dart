import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum AuthProviderType {
  google,
  apple,
  facebook,
  email,
  anonymous,
}

extension AuthProviderTypeX on AuthProviderType {
  String get label {
    switch (this) {
      case AuthProviderType.google:
        return 'Google';
      case AuthProviderType.apple:
        return 'Apple';
      case AuthProviderType.facebook:
        return 'Facebook';
      case AuthProviderType.email:
        return 'Email';
      case AuthProviderType.anonymous:
        return 'Anonyme';
    }
  }

  String get emoji {
    switch (this) {
      case AuthProviderType.google:
        return 'G';
      case AuthProviderType.apple:
        return '';
      case AuthProviderType.facebook:
        return 'f';
      case AuthProviderType.email:
        return '✉';
      case AuthProviderType.anonymous:
        return '👤';
    }
  }
}

class AuthSession {
  final String id;
  final AuthProviderType provider;
  final String displayName;
  final String? email;

  const AuthSession({
    required this.id,
    required this.provider,
    required this.displayName,
    this.email,
  });

  bool get isAnonymous => provider == AuthProviderType.anonymous;

  String get storageKey => '${provider.name}_$id';

  Map<String, dynamic> toJson() => {
        'id': id,
        'provider': provider.name,
        'displayName': displayName,
        'email': email,
      };

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      id: json['id'] as String,
      provider: AuthProviderType.values.firstWhere(
        (value) => value.name == json['provider'],
      ),
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
    );
  }
}

class AuthState {
  final bool isLoading;
  final AuthSession? session;
  final bool isLocalMode;

  const AuthState({
    this.isLoading = true,
    this.session,
    this.isLocalMode = true,
  });

  AuthState copyWith({
    bool? isLoading,
    AuthSession? session,
    bool clearSession = false,
    bool? isLocalMode,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      session: clearSession ? null : (session ?? this.session),
      isLocalMode: isLocalMode ?? this.isLocalMode,
    );
  }
}

class AuthFailure implements Exception {
  final String message;

  const AuthFailure(this.message);

  @override
  String toString() => message;
}

final authSessionProvider =
    StateNotifierProvider<AuthSessionNotifier, AuthState>((ref) {
  return AuthSessionNotifier();
});

class AuthSessionNotifier extends StateNotifier<AuthState> {
  AuthSessionNotifier() : super(const AuthState()) {
    _load();
  }

  static const _sessionKey = 'auth_session';
  static const _emailAccountsKey = 'auth_email_accounts';
  final _uuid = const Uuid();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawSession = prefs.getString(_sessionKey);

    if (rawSession == null || rawSession.isEmpty) {
      state = state.copyWith(isLoading: false, clearSession: true);
      return;
    }

    final decoded = jsonDecode(rawSession) as Map<String, dynamic>;
    state = state.copyWith(
      isLoading: false,
      session: AuthSession.fromJson(decoded),
    );
  }

  Future<void> _persistSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
    state = state.copyWith(isLoading: false, session: session);
  }

  Future<void> signInWithGoogle() async {
    await _persistSession(
      const AuthSession(
        id: 'demo_google',
        provider: AuthProviderType.google,
        displayName: 'Google Player',
        email: 'google@test.local',
      ),
    );
  }

  Future<void> signInWithApple() async {
    await _persistSession(
      const AuthSession(
        id: 'demo_apple',
        provider: AuthProviderType.apple,
        displayName: 'Apple Player',
        email: 'apple@test.local',
      ),
    );
  }

  Future<void> signInWithFacebook() async {
    await _persistSession(
      const AuthSession(
        id: 'demo_facebook',
        provider: AuthProviderType.facebook,
        displayName: 'Facebook Player',
        email: 'facebook@test.local',
      ),
    );
  }

  Future<void> signInAnonymously() async {
    await _persistSession(
      AuthSession(
        id: _uuid.v4(),
        provider: AuthProviderType.anonymous,
        displayName: 'Invité Sushi',
      ),
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw const AuthFailure('Adresse email invalide');
    }

    if (normalizedPassword.length < 4) {
      throw const AuthFailure('Le mot de passe doit contenir au moins 4 caractères');
    }

    final prefs = await SharedPreferences.getInstance();
    final rawAccounts = prefs.getString(_emailAccountsKey);
    final decodedAccounts = rawAccounts == null || rawAccounts.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(rawAccounts) as Map<String, dynamic>;

    final existing = decodedAccounts[normalizedEmail] as Map<String, dynamic>?;
    if (existing != null) {
      if (existing['password'] != normalizedPassword) {
        throw const AuthFailure('Mot de passe incorrect');
      }
    } else {
      decodedAccounts[normalizedEmail] = {
        'password': normalizedPassword,
        'displayName': (displayName == null || displayName.trim().isEmpty)
            ? normalizedEmail.split('@').first
            : displayName.trim(),
      };
      await prefs.setString(_emailAccountsKey, jsonEncode(decodedAccounts));
    }

    final account = decodedAccounts[normalizedEmail] as Map<String, dynamic>;

    await _persistSession(
      AuthSession(
        id: normalizedEmail.replaceAll(RegExp(r'[^a-z0-9]'), '_'),
        provider: AuthProviderType.email,
        displayName: account['displayName'] as String,
        email: normalizedEmail,
      ),
    );
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    state = state.copyWith(isLoading: false, clearSession: true);
  }
}