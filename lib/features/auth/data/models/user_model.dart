import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.student,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role.name,
      };
}