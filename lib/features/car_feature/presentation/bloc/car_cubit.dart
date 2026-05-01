import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_rental_app/features/car_feature/data/models/car_model.dart';
import 'package:car_rental_app/features/car_feature/data/repositories/car_repository.dart';

abstract class CarState {}

class CarLoading extends CarState {}

class CarLoaded extends CarState {
  final List<CarModel> cars;
  CarLoaded(this.cars);
}

class CarError extends CarState {
  final String message;
  CarError(this.message);
}

class CarCubit extends Cubit<CarState> {
  final CarRepository repository;
  StreamSubscription? _subscription;

  CarCubit(this.repository) : super(CarLoading()) {
    _startListening();
  }

  void _startListening() {
    _subscription = repository.getCars().listen(
      (cars) => emit(CarLoaded(cars)),
      onError: (err) => emit(CarError(err.toString())),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
