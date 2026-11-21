import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';

/// All Firestore reads and writes go through this class, so every module
/// uses the same collection names and fields.
///
///   final db = FirestoreService();
///   final bus = await db.getBusByPlate('WXY 1234');
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _operators => _db.collection('operators');
  CollectionReference<Map<String, dynamic>> get _buses => _db.collection('buses');
  CollectionReference<Map<String, dynamic>> get _trips => _db.collection('trips');
  CollectionReference<Map<String, dynamic>> get _violations => _db.collection('violations');
  CollectionReference<Map<String, dynamic>> get _ratings => _db.collection('ratings');

  // ---------------------------------------------------------------- Users

  /// Called after registration. New users are always passengers.
  Future<void> createUserProfile(AppUser user) =>
      _users.doc(user.uid).set(user.toMap());

  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.exists ? AppUser.fromDoc(doc) : null;
  }

  // ------------------------------------------------------------ Operators

  Future<Operator?> getOperator(String operatorId) async {
    final doc = await _operators.doc(operatorId).get();
    return doc.exists ? Operator.fromDoc(doc) : null;
  }

  Future<List<Operator>> getOperators() async {
    final snap = await _operators.orderBy('name').get();
    return snap.docs.map(Operator.fromDoc).toList();
  }

  // ---------------------------------------------------------------- Buses

  /// Plate Number Search. Accepts "WXY 1234", "wxy1234", "WXY-1234".
  Future<Bus?> getBusByPlate(String plate) async {
    final snap = await _buses
        .where('plateKey', isEqualTo: Bus.normalizePlate(plate))
        .limit(1)
        .get();
    return snap.docs.isEmpty ? null : Bus.fromDoc(snap.docs.first);
  }

  /// QR Code Scanning: the QR code contains the bus document ID.
  Future<Bus?> getBusById(String busId) async {
    final doc = await _buses.doc(busId).get();
    return doc.exists ? Bus.fromDoc(doc) : null;
  }

  Future<List<Bus>> getBusesByOperator(String operatorId) async {
    final snap = await _buses.where('operatorId', isEqualTo: operatorId).get();
    return snap.docs.map(Bus.fromDoc).toList();
  }

  Stream<List<Bus>> streamBuses() => _buses
      .snapshots()
      .map((snap) => snap.docs.map(Bus.fromDoc).toList());

  // ---------------------------------------------------------------- Trips

  /// Returns the new trip ID.
  Future<String> startTrip(Trip trip) async {
    final ref = await _trips.add(trip.toMap());
    return ref.id;
  }

  /// Called every few seconds during a trip (feeds Live Bus Monitoring).
  Future<void> updateTripProgress(
    String tripId, {
    required GeoPoint location,
    required double speedKmh,
  }) =>
      _trips.doc(tripId).update({
        'lastLocation': location,
        'lastSpeedKmh': speedKmh,
      });

  /// Saves the final trip summary (status completed or discarded).
  Future<void> endTrip(Trip trip) => _trips.doc(trip.id).update(trip.toMap());

  /// Live Bus Monitoring on the dashboard.
  Stream<List<Trip>> streamActiveTrips() => _trips
      .where('status', isEqualTo: TripStatus.active.name)
      .snapshots()
      .map((snap) => snap.docs.map(Trip.fromDoc).toList());

  /// Completed trips of one bus, newest first (Bus Rating input).
  Future<List<Trip>> getCompletedTripsForBus(String busId, {DateTime? since}) async {
    Query<Map<String, dynamic>> q = _trips
        .where('busId', isEqualTo: busId)
        .where('status', isEqualTo: TripStatus.completed.name);
    if (since != null) {
      q = q.where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(since));
    }
    final snap = await q.orderBy('startTime', descending: true).get();
    return snap.docs.map(Trip.fromDoc).toList();
  }

  // ----------------------------------------------------------- Violations

  Future<void> addViolation(Violation v) => _violations.add(v.toMap());

  /// Violations of one bus, newest first (Rating, Bus Profile, Dashboard).
  Future<List<Violation>> getViolationsForBus(
    String busId, {
    DateTime? since,
    int? limit,
  }) async {
    Query<Map<String, dynamic>> q = _violations.where('busId', isEqualTo: busId);
    if (since != null) {
      q = q.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(since));
    }
    q = q.orderBy('timestamp', descending: true);
    if (limit != null) q = q.limit(limit);
    final snap = await q.get();
    return snap.docs.map(Violation.fromDoc).toList();
  }

  Future<List<Violation>> getViolationsForTrip(String tripId) async {
    final snap = await _violations.where('tripId', isEqualTo: tripId).get();
    return snap.docs.map(Violation.fromDoc).toList();
  }

  /// Live alerts + Violation Log Review on the dashboard.
  Stream<List<Violation>> streamRecentViolations({int limit = 50}) => _violations
      .orderBy('timestamp', descending: true)
      .limit(limit)
      .snapshots()
      .map((snap) => snap.docs.map(Violation.fromDoc).toList());

  // -------------------------------------------------------------- Ratings

  Future<Rating?> getRating(String busId) async {
    final doc = await _ratings.doc(busId).get();
    return doc.exists ? Rating.fromDoc(doc) : null;
  }

  Stream<Rating?> streamRating(String busId) => _ratings
      .doc(busId)
      .snapshots()
      .map((doc) => doc.exists ? Rating.fromDoc(doc) : null);

  Future<void> saveRating(Rating rating) =>
      _ratings.doc(rating.busId).set(rating.toMap());

  /// Operator-level safety rankings / bus list sorted by score.
  Future<List<Rating>> getAllRatings() async {
    final snap = await _ratings.orderBy('score', descending: true).get();
    return snap.docs.map(Rating.fromDoc).toList();
  }
}
