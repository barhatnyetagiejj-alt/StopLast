import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  SharedPreferences? _prefs;
  String? _currentUser;

  static const _kUsersKey = 'ls_users';
  static const _kCurrentUserKey = 'ls_current_user';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _currentUser = _prefs?.getString(_kCurrentUserKey);
  }

  String? get currentUser => _currentUser;

  String _hash(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Map<String, String> _readUsers() {
    final raw = _prefs?.getString(_kUsersKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (e) {
      return {};
    }
  }

  Future<bool> register(String login, String password) async {
    final users = _readUsers();
    if (users.containsKey(login)) return false; // already exists
    final hashed = _hash(password);
    users[login] = hashed;
    await _prefs?.setString(_kUsersKey, jsonEncode(users));
    await _prefs?.setString(_kCurrentUserKey, login);
    _currentUser = login;
    return true;
  }

  Future<bool> login(String login, String password) async {
    final users = _readUsers();
    if (!users.containsKey(login)) return false;
    final hashed = _hash(password);
    if (users[login] == hashed) {
      await _prefs?.setString(_kCurrentUserKey, login);
      _currentUser = login;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _prefs?.remove(_kCurrentUserKey);
    _currentUser = null;
  }
}
