import 'package:cloud_firestore/cloud_firestore.dart';

/// One point on the rating trend chart.
class RatingPoint {
  final DateTime date;
  final double score;

  const RatingPoint({required this.date, required this.score});

  factory RatingPoint.fromMap(Map<String, dynamic> map) => RatingPoint(
        date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        score: (map['score'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(date),
        'score': score,
      };
}

/// A bus's safety score. Stored in `ratings/{busId}` (document ID = bus ID).
///
/// Calculated in the app by Bus Rating: base score 100 minus weighted
/// penalties, with time decay for older trips (proposal section 5.2).
class Rating {
  /// The proposal says a rating is shown only "after several trips".
  static const int minTripsForRating = 3;

  /// How many points the trend list keeps.
  static const int maxTrendPoints = 12;

  final String busId;

  /// 0 - 100. Higher is safer.
  final double score;

  /// Penalty points per input, used for "Score Explanation", e.g.
  /// {frequency: 8.5, duration: 3.0, magnitude: 6.2, harshEvents: 1.0, highRiskZone: 4.0}
  final Map<String, double> penalties;

  final int tripsCounted;

  /// For text like "12 speeding events logged in the last 30 days".
  final int violationsLast30Days;
  final List<RatingPoint> trend;
  final DateTime updatedAt;

  const Rating({
    required this.busId,
    required this.score,
    this.penalties = const {},
    this.tripsCounted = 0,
    this.violationsLast30Days = 0,
    this.trend = const [],
    required this.updatedAt,
  });

  /// True until the bus has enough trips for a meaningful rating.
  bool get isProvisional => tripsCounted < minTripsForRating;

  factory Rating.fromMap(String busId, Map<String, dynamic> map) => Rating(
        busId: busId,
        score: (map['score'] as num?)?.toDouble() ?? 100,
        penalties: (map['penalties'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
        tripsCounted: (map['tripsCounted'] as num?)?.toInt() ?? 0,
        violationsLast30Days: (map['violationsLast30Days'] as num?)?.toInt() ?? 0,
        trend: (map['trend'] as List<dynamic>? ?? [])
            .map((e) => RatingPoint.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  factory Rating.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Rating.fromMap(doc.id, doc.data() ?? {});

  Map<String, dynamic> toMap() => {
        'score': score,
        'penalties': penalties,
        'tripsCounted': tripsCounted,
        'violationsLast30Days': violationsLast30Days,
        'trend': trend.map((p) => p.toMap()).toList(),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
