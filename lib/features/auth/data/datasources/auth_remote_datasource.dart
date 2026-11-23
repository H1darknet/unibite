import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({required this.auth, required this.firestore});

  CollectionReference<Map<String, dynamic>> get _users =>
      firestore.collection('users');

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final cred = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _fetchUser(cred.user!.uid);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Yangi foydalanuvchi doim talaba bo'ladi.
    final user = UserModel(
      uid: cred.user!.uid,
      name: name,
      email: email,
      role: UserRole.student,
    );
    await _users.doc(user.uid).set(user.toMap());
    return user;
  }

  @override
  Future<void> logout() => auth.signOut();

  @override
  Future<UserModel?> getCurrentUser() async {
    final current = auth.currentUser;
    if (current == null) return null;
    return _fetchUser(current.uid);
  }

  Future<UserModel> _fetchUser(String uid) async {
    final doc = await _users.doc(uid).get();
    final data = doc.data();
    if (data == null) {
      throw const AuthException('Foydalanuvchi ma\'lumotlari topilmadi');
    }
    return UserModel.fromMap(data, uid);
  }
}