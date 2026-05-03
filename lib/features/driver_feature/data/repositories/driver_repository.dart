import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_rental_app/core/network/firebase_collections.dart';
import 'package:car_rental_app/features/driver_feature/data/models/driver_model.dart';
import 'package:car_rental_app/features/home_feature/data/data_source/local/sample_data.dart';

class DriverRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<DriverModel>> getDrivers() {
    return _firestore
        .collection(FirebaseCollections.drivers)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DriverModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> seedMockDriversIfEmpty() async {
    try {
      final snapshot =
          await _firestore.collection(FirebaseCollections.drivers).limit(1).get();
      if (snapshot.docs.isEmpty) {
        print("Empty drivers collection detected, seeding drivers...");
        final batch = _firestore.batch();
        for (var driverMap in sampleDrivers) {
          final docRef = _firestore.collection(FirebaseCollections.drivers).doc();
          // Converting sample mock driver to standard json
          final map = {
            'name': driverMap['name'],
            'image': driverMap['image'],
            'category': driverMap['category'],
            'experience': driverMap['experience'],
            'rating': driverMap['rating'],
            'price': driverMap['price'],
            'languages': driverMap['languages'],
            'totalTrips': 0,
            'phone': '+1234567890',
            'isAvailable': true,
          };
          batch.set(docRef, map);
        }
        await batch.commit();
        print("Successfully seeded drivers.");
      }
    } catch (e) {
      print("Firebase driver seeding error: \$e");
    }
  }
}
