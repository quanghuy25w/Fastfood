import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin == true;

  static const _prefsUserId = 'user_id';

  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    final id = p.getInt(_prefsUserId);
    if (id != null) {
      _user = await ApiService.instance.getUserById(id);
      if (_user == null) await p.remove(_prefsUserId);
    }
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    final u = await ApiService.instance.login(email, password);
    if (u == null) return 'Email hoặc mật khẩu không đúng';
    _user = u;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_prefsUserId, u.id);
    notifyListeners();
    return null;
  }

  Future<String?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final u = await ApiService.instance.register(
        email: email,
        password: password,
        name: name,
      );
      _user = u;
      final p = await SharedPreferences.getInstance();
      await p.setInt(_prefsUserId, u.id);
      notifyListeners();
      return null;
    } on DatabaseException {
      return 'Email đã được sử dụng';
    } catch (_) {
      return 'Đăng ký thất bại';
    }
  }

  Future<void> logout() async {
    _user = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_prefsUserId);
    notifyListeners();
  }

  Future<void> saveAddress(String addressJson) async {
    if (_user == null) return;
    await ApiService.instance.updateUserAddress(_user!.id, addressJson);
    _user = _user!.copyWith(address: addressJson);
    notifyListeners();
  }

  void refreshUserFromDb() async {
    if (_user == null) return;
    final u = await ApiService.instance.getUserById(_user!.id);
    if (u != null) {
      _user = u;
      notifyListeners();
    }
  }
}
