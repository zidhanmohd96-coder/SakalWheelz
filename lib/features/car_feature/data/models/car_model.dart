class CarHost {
  final String name;
  final String trips;
  final String image;
  final String phone;

  CarHost({required this.name, required this.trips, required this.image, required this.phone});

  factory CarHost.fromJson(Map<String, dynamic> json) {
    return CarHost(
      name: json['name']?.toString() ?? 'Unknown Host',
      trips: json['trips']?.toString() ?? '0',
      image: json['image']?.toString() ?? 'https://randomuser.me/api/portraits/men/32.jpg',
      phone: json['phone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'trips': trips,
    'image': image,
    'phone': phone,
  };
}

class CarModel {
  final String id;
  final String brand;
  final String name;
  final double price;
  final double rating;
  final List<String> images;
  final String description;
  final String location;
  final String transmission;
  final String fuel;
  final String seats;
  final String model;
  final String type;
  final List<String> features;
  final CarHost host;

  CarModel({
    required this.id,
    required this.brand,
    required this.name,
    required this.price,
    required this.rating,
    required this.images,
    required this.description,
    required this.location,
    required this.transmission,
    required this.fuel,
    required this.seats,
    required this.model,
    required this.type,
    required this.features,
    required this.host,
  });

  factory CarModel.fromJson(Map<String, dynamic> json, String documentId) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return CarModel(
      id: documentId,
      brand: json['brand']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: parseDouble(json['price']),
      rating: parseDouble(json['rating']),
      images: List<String>.from(json['images'] ?? []),
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      transmission: json['transmission']?.toString() ?? '',
      fuel: json['fuel']?.toString() ?? '',
      seats: json['seats']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      features: List<String>.from(json['features'] ?? []),
      host: CarHost.fromJson(json['host'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'brand': brand,
    'name': name,
    'price': price,
    'rating': rating,
    'images': images,
    'description': description,
    'location': location,
    'transmission': transmission,
    'fuel': fuel,
    'seats': seats,
    'model': model,
    'type': type,
    'features': features,
    'host': host.toJson(),
  };
}
