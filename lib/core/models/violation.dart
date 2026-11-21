import 'package:cloud_firestore/cloud_firestore.dart';

/// Alert levels from proposal section 5.1: "warning" -> "danger" -> "critical".
/// The exact km/h thresholds are decided in the Speed Alert module.
enum Severity { warning, danger, critical }

/// One speeding event. Stored in `violations/{violationId}`.
///
/// Written by Speed Alert ("logged with its time, location, recorded speed
/// and posted limit"). Read by Bus Rating, Plate Lookup and the Dashboard.
/// Agree with the team before changing any field here.
class Violation {
  final String id;
  final String tripId;
  final String busId;
  final String userId;
  final DateTime timestamp;
  final GeoPoint location;

  /// Highest speed recorded during this violation.
  final double speedKmh;

  /// Posted road speed limit at that location.
  final double limitKmh;

  /// How long the bus stayed above the limit (rating input: duration).
  final int durationSec;
  final Severity severity;
  final String? roadName;

  /// Sharp curve / hilly stretch etc. (rating input: high-risk-zone speeding).
  final bool highRiskZone;

  const Violation({
    this.id = '',
    required this.tripId,
    required this.busId,
    required this.userId,
    required this.timestamp,
    required this.location,
    required this.speedKmh,
    required this.limitKmh,
    this.durationSec = 0,
    required this.severity,
    this.roadName,
    this.highRiskZone = false,
  });

  /// Rating input: overspeed magnitude.
  double get excessKmh => speedKmh - limitKmh;
  double get excessPercent => limitKmh == 0 ? 0 : excessKmh / limitKmh * 100;

  factory Violation.fromMap(String id, Map<String, dynamic> map) => Violation(
        id: id,
        tripId: map['tripId'] as String? ?? '',
        busId: map['busId'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        location: map['location'] as GeoPoint? ?? const GeoPoint(0, 0),
        speedKmh: (map['speedKmh'] as num?)?.toDouble() ?? 0,
        limitKmh: (map['limitKmh'] as num?)?.toDouble() ?? 0,
        durationSec: (map['durationSec'] as num?)?.toInt() ?? 0,
        severity: Severity.values.asNameMap()[map['severity']] ?? Severity.warning,
        roadName: map['roadName'] as String?,
        highRiskZone: map['highRiskZone'] as bool? ?? false,
      );

  factory Violation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Violation.fromMap(doc.id, doc.data() ?? {});

  Map<String, dynamic> toMap() => {
        'tripId': tripId,
        'busId': busId,
        'userId': userId,
        'timestamp': Timestamp.fromDate(timestamp),
        'location': location,
        'speedKmh': speedKmh,
        'limitKmh': limitKmh,
        'durationSec': durationSec,
        'severity': severity.name,
        'roadName': roadName,
        'highRiskZone': highRiskZone,
      };
}
