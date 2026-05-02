import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_rental_app/core/network/firebase_collections.dart';
import 'package:car_rental_app/features/booking_feature/data/models/booking_model.dart';

/// Repository for all booking CRUD operations against Firestore.
class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _bookingsRef =>
      _firestore.collection(FirebaseCollections.bookings);

  // ---------------------------------------------------------------------------
  // CREATE
  // ---------------------------------------------------------------------------

  /// Creates a new booking document in Firestore and returns the generated ID.
  Future<String> createBooking(BookingModel booking) async {
    try {
      final docRef = await _bookingsRef.add(booking.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // READ
  // ---------------------------------------------------------------------------

  /// Real-time stream of bookings for a specific customer (sorted client-side).
  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _bookingsRef
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => BookingModel.fromJson(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      // Sort newest first (client-side avoids needing a composite index)
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Real-time stream of bookings where the host name matches (for Host mode).
  Stream<List<BookingModel>> getHostBookings(String hostName) {
    return _bookingsRef
        .where('host_name', isEqualTo: hostName)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => BookingModel.fromJson(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// One-time fetch of a single booking by ID.
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _bookingsRef.doc(bookingId).get();
      if (doc.exists) {
        return BookingModel.fromJson(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch booking: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE
  // ---------------------------------------------------------------------------

  /// Cancel a booking (sets status to 'Cancelled').
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _bookingsRef.doc(bookingId).update({'status': 'Cancelled'});
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  /// Accept a booking (for Host mode — sets status to 'Confirmed').
  Future<void> acceptBooking(String bookingId) async {
    try {
      await _bookingsRef.doc(bookingId).update({'status': 'Confirmed'});
    } catch (e) {
      throw Exception('Failed to accept booking: $e');
    }
  }

  /// Reject a booking (for Host mode).
  Future<void> rejectBooking(String bookingId) async {
    try {
      await _bookingsRef.doc(bookingId).update({'status': 'Rejected'});
    } catch (e) {
      throw Exception('Failed to reject booking: $e');
    }
  }

  /// Mark a booking as completed.
  Future<void> completeBooking(String bookingId) async {
    try {
      await _bookingsRef.doc(bookingId).update({'status': 'Completed'});
    } catch (e) {
      throw Exception('Failed to complete booking: $e');
    }
  }
}
