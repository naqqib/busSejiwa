import 'package:cloud_firestore/cloud_firestore.dart';

/// Bus service types issued by APAD (proposal section 1.1).
enum BusType { express, stage, charter, excursion }

/// A bus profile. Stored in `buses/{busId}`. Written by admins only.
///
/// Plate-Number Lookup searches by [plateKey]; QR Code Scanning reads the
/// bus document ID from the QR code (the QR simply encodes [id]).
class Bus {
  final String id;

  /// Plate as displayed, e.g. "WXY 1234".
  final String plateNumber;
  final String operatorId;

  /// Copied from the operator so the profile page needs one read only.
  final String operatorName;
  final String model;
  final String route;
  final BusType busType;

  /// Only shown "where official data is integrated" (proposal 5.1).
  final String? permitStatus;
  final String? inspectionStatus;
  final DateTime createdAt;

  const Bus({
    required this.id,
    required this.plateNumber,
    required this.operatorId,
    required this.operatorName,
    required this.model,
    required this.route,
    this.busType = BusType.express,
    this.permitStatus,
    this.inspectionStatus,
    required this.createdAt,
  });

  /// "wxy 1234", "WXY-1234" and "WXY1234" all become "WXY1234".
  static String normalizePlate(String plate) =>
      plate.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  String get plateKey => normalizePlate(plateNumber);

  factory Bus.fromMap(String id, Map<String, dynamic> map) => Bus(
        id: id,
        plateNumber: map['plateNumber'] as String? ?? '',
        operatorId: map['operatorId'] as String? ?? '',
        operatorName: map['operatorName'] as String? ?? '',
        model: map['model'] as String? ?? '',
        route: map['route'] as String? ?? '',
        busType: BusType.values.asNameMap()[map['busType']] ?? BusType.express,
        permitStatus: map['permitStatus'] as String?,
        inspectionStatus: map['inspectionStatus'] as String?,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  factory Bus.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Bus.fromMap(doc.id, doc.data() ?? {});

  Map<String, dynamic> toMap() => {
        'plateNumber': plateNumber,
        'plateKey': plateKey,
        'operatorId': operatorId,
        'operatorName': operatorName,
        'model': model,
        'route': route,
        'busType': busType.name,
        'permitStatus': permitStatus,
        'inspectionStatus': inspectionStatus,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
