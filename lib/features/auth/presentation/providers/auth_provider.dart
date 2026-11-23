import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final GetCurrentUserUseCase _getCurrentUser;

  AuthProvider({
    required this._login,
    required this._register,
    required this._logout,
    required this._getCurrentUser,
  });

  AuthStatus _status = AuthStatus.unknown;
  UserEntity? _user;
  bool _isLoading = false;
  String? _error;

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Ilova ochilganda foydalanuvchi allaqachon kirganmi, tekshiradi.
  Future<void> checkAuth() async {
    final result = await _getCurrentUser();
    result.fold(
      (_) => _status = AuthStatus.unauthenticated,
      (user) {
        _user = user;
        _status =
            user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
      },
    );
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) {
    return _run(() => _login(email: email, password: password));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(
      () => _register(name: name, email: email, password: password),
    );
  }

  Future<void> logout() async {
    await _logout();
    _user = null;
    _error = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> _run(
    Future<Either<Failure, UserEntity>> Function() action,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await action();

    var success = false;
    result.fold(
      (failure) => _error = failure.message,
      (user) {
        _user = user;
        _status = AuthStatus.authenticated;
        success = true;
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }
}