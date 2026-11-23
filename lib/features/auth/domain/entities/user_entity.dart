import 'package:equatable/equatable.dart';

enum UserRole { student, admin }

class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [uid, name, email, role];
}