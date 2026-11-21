import 'package:cloud_firestore/cloud_firestore.dart';

/// `discarded` = trip excluded from rating (poor GPS accuracy or too short,
/// proposal section 5.4).
enum TripStatus { active, completed, discarded }

/// One passenger journey on one bus. Stored in `trips/{tripId}`.
///
/// - Speed Alert creates it when the trip starts and updates
///   [lastLocation]/[lastSpeedKmh] while it runs.
/// - The Dashboard listens to active trips for Live Bus Monitoring.
/// - Bus Rating reads completed trips to calculate the score.
class Trip {
  final String id;
  final String busId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final TripStatus status;

  final double distanceKm;
  final double maxSpeedKmh;
  final double avgSpeedKmh;

  /// Average GPS accuracy in metres (lower is better).
  final double avgGpsAccuracyM;
  final int violationCount;

  /// Sudden braking / acceleration events (rating input).
  final int harshEventCount;

  /// Latest position, for the live map.
  final GeoPoint? lastLocation;
  final double lastSpeedKmh;

  const Trip({
    this.id = '',
    required this.busId,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.status = TripStatus.active,
    this.distanceKm = 0,
    this.maxSpeedKmh = 0,
    this.avgSpeedKmh = 0,
    this.avgGpsAccuracyM = 0,
    this.violationCount = 0,
    this.harshEventCount = 0,
    this.lastLocation,
    this.lastSpeedKmh = 0,
  });

  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);

  factory Trip.fromMap(String id, Map<String, dynamic> map) => Trip(
        id: id,
        busId: map['busId'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        startTime: (map['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        endTime: (map['endTime'] as Timestamp?)?.toDate(),
        status: TripStatus.values.asNameMap()[map['status']] ?? TripStatus.active,
        distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
        maxSpeedKmh: (map['maxSpeedKmh'] as num?)?.toDouble() ?? 0,
        avgSpeedKmh: (map['avgSpeedKmh'] as num?)?.toDouble() ?? 0,
        avgGpsAccuracyM: (map['avgGpsAccuracyM'] as num?)?.toDouble() ?? 0,
        violationCount: (map['violationCount'] as num?)?.toInt() ?? 0,
        harshEventCount: (map['harshEventCount'] as num?)?.toInt() ?? 0,
        lastLocation: map['lastLocation'] as GeoPoint?,
        lastSpeedKmh: (map['lastSpeedKmh'] as num?)?.toDouble() ?? 0,
      );

  factory Trip.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Trip.fromMap(doc.id, doc.data() ?? {});

  Map<String, dynamic> toMap() => {
        'busId': busId,
        'userId': userId,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': endTime == null ? null : Timestamp.fromDate(endTime!),
        'status': status.name,
        'distanceKm': distanceKm,
        'maxSpeedKmh': maxSpeedKmh,
        'avgSpeedKmh': avgSpeedKmh,
        'avgGpsAccuracyM': avgGpsAccuracyM,
        'violationCount': violationCount,
        'harshEventCount': harshEventCount,
        'lastLocation': lastLocation,
        'lastSpeedKmh': lastSpeedKmh,
      };

  Trip copyWith({
    DateTime? endTime,
    TripStatus? status,
    double? distanceKm,
    double? maxSpeedKmh,
    double? avgSpeedKmh,
    double? avgGpsAccuracyM,
    int? violationCount,
    int? harshEventCount,
    GeoPoint? lastLocation,
    double? lastSpeedKmh,
  }) =>
      Trip(
        id: id,
        busId: busId,
        userId: userId,
        startTime: startTime,
        endTime: endTime ?? this.endTime,
        status: status ?? this.status,
        distanceKm: distanceKm ?? this.distanceKm,
        maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
        avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
        avgGpsAccuracyM: avgGpsAccuracyM ?? this.avgGpsAccuracyM,
        violationCount: violationCount ?? this.violationCount,
        harshEventCount: harshEventCount ?? this.harshEventCount,
        lastLocation: lastLocation ?? this.lastLocation,
        lastSpeedKmh: lastSpeedKmh ?? this.lastSpeedKmh,
      );
}
