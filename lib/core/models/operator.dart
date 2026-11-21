import 'package:cloud_firestore/cloud_firestore.dart';

/// A bus operator company (e.g. an express or charter bus company).
/// Stored in `operators/{operatorId}`. Written by admins only.
class Operator {
  final String id;
  final String name;

  /// APAD permit / licence reference, if known.
  final String? permitNumber;
  final String? contactEmail;
  final String? contactPhone;
  final DateTime createdAt;

  const Operator({
    required this.id,
    required this.name,
    this.permitNumber,
    this.contactEmail,
    this.contactPhone,
    required this.createdAt,
  });

  factory Operator.fromMap(String id, Map<String, dynamic> map) => Operator(
        id: id,
        name: map['name'] as String? ?? '',
        permitNumber: map['permitNumber'] as String?,
        contactEmail: map['contactEmail'] as String?,
        contactPhone: map['contactPhone'] as String?,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  factory Operator.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Operator.fromMap(doc.id, doc.data() ?? {});

  Map<String, dynamic> toMap() => {
        'name': name,
        'permitNumber': permitNumber,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
