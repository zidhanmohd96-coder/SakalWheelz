import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 1. Define the State
class BottomNavigationState extends Equatable {
  final int selectedIndex;

  const BottomNavigationState({required this.selectedIndex});

  @override
  List<Object> get props => [selectedIndex];
}

// 2. Define the Cubit
class BottomNavigationCubit extends Cubit<BottomNavigationState> {
  // Initialize with 0 by default to prevent "Null" errors
  BottomNavigationCubit()
      : super(const BottomNavigationState(selectedIndex: 0));

  void onItemTap({required int index}) {
    emit(BottomNavigationState(selectedIndex: index));
  }
}
