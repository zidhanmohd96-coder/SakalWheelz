import 'package:flutter/material.dart';

enum AppMode { customer, host, driver }

class RoleManager extends ChangeNotifier {
  // Singleton Pattern (One instance for the whole app)
  static final RoleManager _instance = RoleManager._internal();
  factory RoleManager() => _instance;
  RoleManager._internal();

  // -- State --
  AppMode _currentMode = AppMode.customer;

  // Roles (Default: Just a customer)
  bool _isCustomer = true;
  bool _isHost = false;
  bool _isDriver = false;

  // -- Getters --
  AppMode get currentMode => _currentMode;
  bool get isHost => _isHost;
  bool get isDriver => _isDriver;

  // -- Actions --

  /// Switch mode. Returns false if user needs to register first.
  bool switchMode(AppMode newMode) {
    if (newMode == AppMode.host && !_isHost) return false;
    if (newMode == AppMode.driver && !_isDriver) return false;

    _currentMode = newMode;
    notifyListeners(); // This updates the UI immediately
    return true;
  }

  /// Unlock Driver Mode (Call this after successful form submission)
  void registerAsDriver() {
    _isDriver = true;
    _currentMode = AppMode.driver; // Auto-switch to driver
    notifyListeners();
  }

  /// Unlock Host Mode
  void registerAsHost() {
    _isHost = true;
    _currentMode = AppMode.host; // Auto-switch to host
    notifyListeners();
  }

  /// Call this during Splash Screen to restore user's status from Firebase
  void setRoles({required bool isDriver, required bool isHost}) {
    _isDriver = isDriver;
    _isHost = isHost;
    // If they were last in driver mode, you could restore that too,
    // but for now default to customer is safer.
    notifyListeners();
  }
}
