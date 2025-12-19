import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// 🧭 The 3 Modes
enum UserMode { customer, driver, host }

class ModeProvider extends ChangeNotifier {
  // Singleton
  static final ModeProvider _instance = ModeProvider._internal();
  factory ModeProvider() => _instance;
  ModeProvider._internal();

  // -- STATE --
  UserMode _currentMode = UserMode.customer; // Default is always Customer

  // -- ROLES (Permissions) --
  bool _canDrive = false;
  bool _canHost = false;

  // -- GETTERS --
  UserMode get currentMode => _currentMode;
  bool get isDriver => _canDrive;
  bool get isHost => _canHost;

  // -- ACTIONS --

  /// 1. Initialize on App Start (Called in Splash)
  Future<void> syncUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        // Parse Roles
        final roles = data['roles'] as Map<String, dynamic>? ?? {};
        _canDrive = roles['driver'] == true;
        _canHost = roles['host'] == true;

        // Optional: Persist activeMode if you want them to stay in Driver mode on restart
        // For now, per your request "Always enters as CUSTOMER", we leave _currentMode as customer.
        // If you want to remember last mode:
        // final savedMode = data['activeMode'] as String?;
        // if (savedMode == 'driver' && _canDrive) _currentMode = UserMode.driver;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error syncing user data: $e");
    }
  }

  /// 2. Switch Mode (Updates UI + Firebase)
  Future<void> switchMode(UserMode newMode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Validation
    if (newMode == UserMode.driver && !_canDrive) return;
    if (newMode == UserMode.host && !_canHost) return;

    // A. Optimistic Update (Instant UI change)
    _currentMode = newMode;
    notifyListeners();

    // B. Background DB Update
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'activeMode': newMode.name, // "customer", "driver", "host"
      });
    } catch (e) {
      debugPrint("Failed to update activeMode in DB: $e");
    }
  }

  /// 3. Grant Role (Called after Registration Success)
  void unlockRole({bool driver = false, bool host = false}) {
    if (driver) _canDrive = true;
    if (host) _canHost = true;
    notifyListeners();
  }
}
