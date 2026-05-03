import 'package:cloud_firestore/cloud_firestore.dart';

class DriverModel {
  final String id;
  final String name;
  final String image;
  final String category;
  final String experience;
  final double rating;
  final double price; // per day
  final List<String> languages;
  final int totalTrips;
  final String phone;
  final bool isAvailable;

  DriverModel({
    required this.id,
    required this.name,
    required this.image,
    required this.category,
    required this.experience,
    required this.rating,
    required this.price,
    required this.languages,
    required this.totalTrips,
    required this.phone,
    required this.isAvailable,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json, String id) {
    return DriverModel(
      id: id,
      name: json['name'] ?? '',
      image: json['image'] ?? 'https://randomuser.me/api/portraits/men/1.jpg',
      category: json['category'] ?? 'General',
      experience: json['experience'] ?? '0 Years',
      rating: (json['rating'] ?? 0.0).toDouble(),
      price: (json['price'] ?? 0.0).toDouble(),
      languages: List<String>.from(json['languages'] ?? []),
      totalTrips: json['totalTrips'] ?? 0,
      phone: json['phone'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'category': category,
      'experience': experience,
      'rating': rating,
      'price': price,
      'languages': languages,
      'totalTrips': totalTrips,
      'phone': phone,
      'isAvailable': isAvailable,
    };
  }
}
