import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a booking with full Firestore serialization.
/// This replaces the old BookingModel from sample_data.dart.
class BookingModel {
  final String id;
  final String userId;
  final String carId;

  // Car snapshot (stored at booking time so it doesn't change if car is edited)
  final String carBrand;
  final String carName;
  final String carImage;
  final String carType;
  final String carTransmission;

  // Host info
  final String hostName;
  final String hostPhone;

  // Dates & Times
  final DateTime startDate;
  final DateTime endDate;
  final String pickupTime;
  final String dropoffTime;

  // Locations
  final String pickupLocation;
  final String dropoffLocation;

  // Driver Add-on
  final bool hasDriver;
  final String? driverName;
  final double driverCost;

  // Insurance
  final bool hasPremiumInsurance;
  final double insuranceCost;

  // Promo
  final String? promoCode;
  final double promoDiscount;

  // Pricing
  final double basePricePerDay;
  final int rentalDays;
  final double totalPrice;

  // Status: 'Active', 'Completed', 'Cancelled'
  final String status;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.carId,
    required this.carBrand,
    required this.carName,
    required this.carImage,
    required this.carType,
    required this.carTransmission,
    required this.hostName,
    required this.hostPhone,
    required this.startDate,
    required this.endDate,
    required this.pickupTime,
    required this.dropoffTime,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.hasDriver = false,
    this.driverName,
    this.driverCost = 0.0,
    this.hasPremiumInsurance = false,
    this.insuranceCost = 0.0,
    this.promoCode,
    this.promoDiscount = 0.0,
    required this.basePricePerDay,
    required this.rentalDays,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  /// Create from Firestore document
  factory BookingModel.fromJson(Map<String, dynamic> json, String documentId) {
    return BookingModel(
      id: documentId,
      userId: json['user_id'] ?? '',
      carId: json['car_id'] ?? '',
      carBrand: json['car_brand'] ?? '',
      carName: json['car_name'] ?? '',
      carImage: json['car_image'] ?? '',
      carType: json['car_type'] ?? '',
      carTransmission: json['car_transmission'] ?? '',
      hostName: json['host_name'] ?? '',
      hostPhone: json['host_phone'] ?? '',
      startDate: (json['start_date'] as Timestamp).toDate(),
      endDate: (json['end_date'] as Timestamp).toDate(),
      pickupTime: json['pickup_time'] ?? '10:00 AM',
      dropoffTime: json['dropoff_time'] ?? '10:00 AM',
      pickupLocation: json['pickup_location'] ?? '',
      dropoffLocation: json['dropoff_location'] ?? '',
      hasDriver: json['has_driver'] ?? false,
      driverName: json['driver_name'],
      driverCost: _parseDouble(json['driver_cost']),
      hasPremiumInsurance: json['has_premium_insurance'] ?? false,
      insuranceCost: _parseDouble(json['insurance_cost']),
      promoCode: json['promo_code'],
      promoDiscount: _parseDouble(json['promo_discount']),
      basePricePerDay: _parseDouble(json['base_price_per_day']),
      rentalDays: json['rental_days'] ?? 1,
      totalPrice: _parseDouble(json['total_price']),
      status: json['status'] ?? 'Active',
      createdAt: json['created_at'] != null
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert to Firestore-compatible Map
  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'car_id': carId,
        'car_brand': carBrand,
        'car_name': carName,
        'car_image': carImage,
        'car_type': carType,
        'car_transmission': carTransmission,
        'host_name': hostName,
        'host_phone': hostPhone,
        'start_date': Timestamp.fromDate(startDate),
        'end_date': Timestamp.fromDate(endDate),
        'pickup_time': pickupTime,
        'dropoff_time': dropoffTime,
        'pickup_location': pickupLocation,
        'dropoff_location': dropoffLocation,
        'has_driver': hasDriver,
        'driver_name': driverName,
        'driver_cost': driverCost,
        'has_premium_insurance': hasPremiumInsurance,
        'insurance_cost': insuranceCost,
        'promo_code': promoCode,
        'promo_discount': promoDiscount,
        'base_price_per_day': basePricePerDay,
        'rental_days': rentalDays,
        'total_price': totalPrice,
        'status': status,
        'created_at': Timestamp.fromDate(createdAt),
      };

  /// Create a copy with updated status
  BookingModel copyWith({String? status}) {
    return BookingModel(
      id: id,
      userId: userId,
      carId: carId,
      carBrand: carBrand,
      carName: carName,
      carImage: carImage,
      carType: carType,
      carTransmission: carTransmission,
      hostName: hostName,
      hostPhone: hostPhone,
      startDate: startDate,
      endDate: endDate,
      pickupTime: pickupTime,
      dropoffTime: dropoffTime,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      hasDriver: hasDriver,
      driverName: driverName,
      driverCost: driverCost,
      hasPremiumInsurance: hasPremiumInsurance,
      insuranceCost: insuranceCost,
      promoCode: promoCode,
      promoDiscount: promoDiscount,
      basePricePerDay: basePricePerDay,
      rentalDays: rentalDays,
      totalPrice: totalPrice,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  /// Helper: safely parse doubles from Firestore
  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  /// Helper: convert to legacy Map format for existing UI widgets
  Map<String, dynamic> toCarDataMap() => {
        'brand': carBrand,
        'name': carName,
        'images': [carImage],
        'type': carType,
        'transmission': carTransmission,
        'host': {
          'name': hostName,
          'phone': hostPhone,
        },
      };
}
