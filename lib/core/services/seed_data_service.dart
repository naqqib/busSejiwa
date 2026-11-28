import 'package:cloud_firestore/cloud_firestore.dart';

/// Dev-only helper that populates 3 Malaysian demo buses, ratings, and violations.
class SeedDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Seeds demo data atomically using a WriteBatch (safe to re-run anytime).
  Future<void> seedDemoData() async {
    final batch = _db.batch();
    final now = DateTime.now();

    // 1. Three Malaysian demo buses (includes demo_bus_01 for your QR code!)
    final buses = {
      'demo_bus_01': {
        'plateNumber': 'WXY 1234',
        'plateKey': 'WXY1234',
        'operatorName': 'Konsortium Bas Ekspres',
        'route': 'Penang Sentral → TBS Kuala Lumpur',
        'model': 'Scania K410IB',
      },
      'demo_bus_02': {
        'plateNumber': 'PNQ 5678',
        'plateKey': 'PNQ5678',
        'operatorName': 'Utara Liner Express',
        'route': 'Sungai Nibong → Ipoh Amanjaya',
        'model': 'Volvo B11R',
      },
      'demo_bus_03': {
        'plateNumber': 'JDT 9012',
        'plateKey': 'JDT9012',
        'operatorName': 'Selatan Trans',
        'route': 'TBS Kuala Lumpur → Larkin Sentral',
        'model': 'Hino RM2P',
      },
    };

    buses.forEach((id, data) {
      batch.set(_db.collection('buses').doc(id), data);
    });

    // 2. Three Live Safety Ratings (Emerald >=80, Amber 60-79, Red <60)
    final ratings = {
      'demo_bus_01': {
        'busId': 'demo_bus_01',
        'score': 88.5,
        'tripsCounted': 24,
        'violationsLast30Days': 1,
        'updatedAt': Timestamp.fromDate(now),
      },
      'demo_bus_02': {
        'busId': 'demo_bus_02',
        'score': 68.0,
        'tripsCounted': 12,
        'violationsLast30Days': 4,
        'updatedAt': Timestamp.fromDate(now),
      },
      'demo_bus_03': {
        'busId': 'demo_bus_03',
        'score': 45.5,
        'tripsCounted': 3, // Provisional (< minTripsForRating)
        'violationsLast30Days': 9,
        'updatedAt': Timestamp.fromDate(now),
      },
    };

    ratings.forEach((id, data) {
      batch.set(_db.collection('ratings').doc(id), data);
    });

    // 3. Realistic Malaysian highway speeding violations
    final violations = {
      'demo_v_01': {
        'busId': 'demo_bus_01',
        'speedKmh': 102.0,
        'limitKmh': 90.0,
        'roadName': 'PLUS North–South Expy (KM 142)',
        'severity': 'minor',
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
      },
      'demo_v_02': {
        'busId': 'demo_bus_02',
        'speedKmh': 114.0,
        'limitKmh': 90.0,
        'roadName': 'PLUS Highway near Taiping',
        'severity': 'moderate',
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
      },
      'demo_v_03': {
        'busId': 'demo_bus_03',
        'speedKmh': 126.0,
        'limitKmh': 90.0,
        'roadName': 'PLUS Highway near Seremban',
        'severity': 'severe',
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(hours: 6))),
      },
      'demo_v_04': {
        'busId': 'demo_bus_03',
        'speedKmh': 118.0,
        'limitKmh': 90.0,
        'roadName': 'PLUS Highway near Ayer Keroh',
        'severity': 'moderate',
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
      },
    };

    violations.forEach((id, data) {
      batch.set(_db.collection('violations').doc(id), data);
    });

    await batch.commit();
  }
}
