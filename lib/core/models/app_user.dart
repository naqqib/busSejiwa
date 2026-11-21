import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles used for role-based access control (see firestore.rules).
enum UserRole { passenger, operator, admin }

/// A logged-in user. Stored in `users/{uid}` (document ID = Firebase Auth UID).
class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  /// Only set for operator accounts: which operator company they belong to.
  final String? operatorId;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.role = UserRole.passenger,
    this.operatorId,
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isOperator => role == UserRole.operator || role == UserRole.admin;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) => AppUser(
        uid: uid,
        name: map['name'] as String? ?? '',
        email: map['email'] as String? ?? '',
        role: UserRole.values.asNameMap()[map['role']] ?? UserRole.passenger,
        operatorId: map['operatorId'] as String?,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      AppUser.fromMap(doc.id, doc.data() ?? {});

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role.name,
        'operatorId': operatorId,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
