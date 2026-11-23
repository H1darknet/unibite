import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) {
    return _guard<UserEntity>(
      () => remote.login(email: email, password: password),
    );
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _guard<UserEntity>(
      () => remote.register(name: name, email: email, password: password),
    );
  }

  @override
  Future<Either<Failure, void>> logout() {
    return _guard<void>(() => remote.logout());
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() {
    return _guard<UserEntity?>(() => remote.getCurrentUser());
  }

  /// Xatolarni ushlab, Either'ga aylantiradi.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_authMessage(e.code)));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server xatosi yuz berdi'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  String _authMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Email manzili noto\'g\'ri';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email yoki parol noto\'g\'ri';
      case 'email-already-in-use':
        return 'Bu email allaqachon ro\'yxatdan o\'tgan';
      case 'weak-password':
        return 'Parol juda oddiy (kamida 6 ta belgi)';
      case 'network-request-failed':
        return 'Internet aloqasi yo\'q';
      case 'too-many-requests':
        return 'Juda ko\'p urinish. Birozdan keyin qayta urining';
      default:
        return 'Autentifikatsiya xatosi';
    }
  }
}