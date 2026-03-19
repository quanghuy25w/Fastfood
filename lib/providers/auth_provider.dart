import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../services/shared_prefs_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthRepository? authRepository,
    SharedPrefsService? sharedPrefsService,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _sharedPrefsService = sharedPrefsService ?? SharedPrefsService.instance;

  final AuthRepository _authRepository;
  final SharedPrefsService _sharedPrefsService;

  // Quản lý trạng thái đăng nhập/đăng ký.
  User? currentUser;

  // Loading indicator va error message cho UI.
  bool isLoading = false;
  String? errorMessage;

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.login(email, password);
      if (user == null) {
        throw Exception('Email hoặc mật khẩu không đúng');
      }

      currentUser = user;
      // Luôn lưu userId, role và isLoggedIn khi login thành công
      if (user.id != null) {
        await _sharedPrefsService.setUserId(user.id!);
        await _sharedPrefsService.setUserRole(user.role);
        await _sharedPrefsService.setLoggedIn(true);
      } else {
        await _sharedPrefsService.setLoggedIn(true);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(User user) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(user);
      final createdUser = await _authRepository.getUserByEmail(user.email);

      if (createdUser == null) {
        throw Exception('Đăng ký thất bại');
      }

      currentUser = createdUser;
      // Luôn lưu userId, role và isLoggedIn khi register thành công
      if (createdUser.id != null) {
        await _sharedPrefsService.setUserId(createdUser.id!);
        await _sharedPrefsService.setUserRole(createdUser.role);
        await _sharedPrefsService.setLoggedIn(true);
      } else {
        await _sharedPrefsService.setLoggedIn(true);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    unawaited(_sharedPrefsService.clearAll());
    currentUser = null;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final userId = await _sharedPrefsService.getUserId();
      if (userId == null) {
        currentUser = null;
        await _sharedPrefsService.setLoggedIn(false);
      } else {
        currentUser = await _authRepository.getUserById(userId);
        await _sharedPrefsService.setLoggedIn(currentUser != null);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
