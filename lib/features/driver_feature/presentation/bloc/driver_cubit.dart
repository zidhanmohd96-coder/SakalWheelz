import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_rental_app/features/driver_feature/data/models/driver_model.dart';
import 'package:car_rental_app/features/driver_feature/data/repositories/driver_repository.dart';

abstract class DriverState {}

class DriverLoading extends DriverState {}

class DriverLoaded extends DriverState {
  final List<DriverModel> drivers;
  DriverLoaded(this.drivers);
}

class DriverError extends DriverState {
  final String message;
  DriverError(this.message);
}

class DriverCubit extends Cubit<DriverState> {
  final DriverRepository repository;
  StreamSubscription? _subscription;

  DriverCubit(this.repository) : super(DriverLoading()) {
    _startListening();
  }

  void _startListening() {
    _subscription = repository.getDrivers().listen(
      (drivers) => emit(DriverLoaded(drivers)),
      onError: (err) => emit(DriverError(err.toString())),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
