import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_rental_app/core/network/firebase_collections.dart';
import 'package:car_rental_app/features/car_feature/data/models/car_model.dart';
import 'package:car_rental_app/features/home_feature/data/data_source/local/sample_data.dart';

class CarRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CarModel>> getCars() {
    return _firestore.collection(FirebaseCollections.cars).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CarModel.fromJson(doc.data(), doc.id)).toList();
    });
  }

  Future<void> seedMockDataIfEmpty() async {
    try {
      final snapshot = await _firestore.collection(FirebaseCollections.cars).limit(1).get();
      if (snapshot.docs.isEmpty) {
        print("Empty Firebase detected, seeding 30+ cars...");
        final batch = _firestore.batch();
        for (var carMap in carsList) {
          final docRef = _firestore.collection(FirebaseCollections.cars).doc();
          batch.set(docRef, carMap);
        }
        await batch.commit();
        print("Successfully seeded cars.");
      }
    } catch (e) {
      print("Firebase seeding error: \$e");
    }
  }
}
