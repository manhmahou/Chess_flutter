import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/user_account.dart';

class UserDatabase {
  static const String _usersKey = 'users_db_v1';

  Future<List<UserAccount>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => UserAccount.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> createUser({
    required String email,
    required String username,
    required String password,
    String role = 'người chơi',
  }) async {
    final users = await getUsers();

    final duplicated = users.any(
      (u) =>
          u.email.toLowerCase() == email.toLowerCase() ||
          u.username.toLowerCase() == username.toLowerCase(),
    );

    if (duplicated) {
      return false;
    }

    final created = UserAccount(
      email: email,
      username: username,
      password: password,
      role: role,
    );

    users.add(created);
    return _saveUsers(users);
  }

  Future<UserAccount?> authenticate({
    required String username,
    required String password,
  }) async {
    final users = await getUsers();

    try {
      return users.firstWhere(
        (u) =>
            u.username.toLowerCase() == username.toLowerCase() &&
            u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> _saveUsers(List<UserAccount> users) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(users.map((u) => u.toJson()).toList());
    return prefs.setString(_usersKey, raw);
  }
}
