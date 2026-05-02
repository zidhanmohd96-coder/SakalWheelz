import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:car_rental_app/features/booking_feature/data/models/booking_model.dart';
import 'package:car_rental_app/features/booking_feature/data/repositories/booking_repository.dart';

// ============================================================================
// STATES
// ============================================================================

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<BookingModel> bookings;
  BookingLoaded(this.bookings);
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}

/// Temporary state while a booking is being created
class BookingCreating extends BookingState {}

/// State after a booking is successfully created
class BookingCreated extends BookingState {
  final String bookingId;
  BookingCreated(this.bookingId);
}

// ============================================================================
// CUBIT
// ============================================================================

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _repository;
  StreamSubscription? _bookingsSubscription;

  BookingCubit(this._repository) : super(BookingInitial());

  /// Load all bookings for the current user (real-time stream)
  void loadUserBookings() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(BookingError('User not logged in'));
      return;
    }

    emit(BookingLoading());

    _bookingsSubscription?.cancel();
    _bookingsSubscription = _repository.getUserBookings(userId).listen(
      (bookings) => emit(BookingLoaded(bookings)),
      onError: (error) => emit(BookingError(error.toString())),
    );
  }

  /// Create a new booking and save to Firestore
  Future<String?> createBooking(BookingModel booking) async {
    try {
      emit(BookingCreating());
      final bookingId = await _repository.createBooking(booking);
      // Reload bookings after creating
      loadUserBookings();
      return bookingId;
    } catch (e) {
      emit(BookingError(e.toString()));
      return null;
    }
  }

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _repository.cancelBooking(bookingId);
      // Stream will auto-update the UI
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _bookingsSubscription?.cancel();
    return super.close();
  }
}
