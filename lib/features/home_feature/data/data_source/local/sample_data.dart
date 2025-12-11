import 'package:car_rental_app/core/gen/assets.gen.dart';

// --- Consolidated Data Model for UI ---
final List<Map<String, dynamic>> carsList = [
  {
    'brand': 'Maserati',
    'name': 'Granturismo',
    'price': 459.00,
    'rating': 4.8,
    'images': [
      Assets.images.maseratiGranturismo.path,
      Assets.images.banner1.path, // Placeholder for more angles
    ],
    'description':
        'The Maserati GranTurismo is the epitome of Italian luxury and performance. A perfect blend of elegance and raw power.',
    'location': 'Kochi, Kerala',
    'transmission': 'Automatic',
    'fuel': 'Petrol',
    'seats': '4',
    'model': '2023 GT',
    'type': 'Luxury',
    'features': ['Bluetooth', 'GPS', 'Sunroof', 'Heated Seats', '360 Camera'],
    'host': {
      'name': 'Arun Varghese',
      'trips': '124',
      'image': 'https://randomuser.me/api/portraits/men/32.jpg',
      'phone': '+91 9876543210',
    },
  },
  {
    'brand': 'PORSCHE',
    'name': '911 GTS RS',
    'price': 528.00,
    'rating': 4.9,
    'images': [
      Assets.images.porsche911GTSRS.path,
      Assets.images.banner2.path,
    ],
    'description':
        'Experience the raw power and precision of the Porsche 911 GT3 RS. Engineered for adrenaline seekers and driving purists.',
    'location': 'Trivandrum, Kerala',
    'transmission': 'Automatic',
    'fuel': 'Petrol',
    'seats': '2',
    'model': '2024 RS',
    'type': 'Sport',
    'features': [
      'Launch Control',
      'Sport Mode',
      'Ceramic Brakes',
      'Carbon Fiber Interior'
    ],
    'host': {
      'name': 'Sarah John',
      'trips': '89',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'phone': '+91 9876543211',
    },
  },
  {
    'brand': 'BMW',
    'name': 'M3 2024',
    'price': 528.00,
    'rating': 4.7,
    'images': [
      Assets.images.bmwM3.path,
      Assets.images.banner3.path,
    ],
    'description':
        'The BMW M3 Competition offers track-inspired performance with everyday usability. The ultimate driving machine.',
    'location': 'Calicut, Kerala',
    'transmission': 'Automatic',
    'fuel': 'Diesel',
    'seats': '5',
    'model': 'M3 Comp',
    'type': 'Sedan',
    'features': [
      'Apple CarPlay',
      'Android Auto',
      'Lane Assist',
      'Adaptive Cruise'
    ],
    'host': {
      'name': 'Mohammed Fasil',
      'trips': '210',
      'image': 'https://randomuser.me/api/portraits/men/65.jpg',
      'phone': '+91 9876543212',
    },
  },
  {
    'brand': 'Porche',
    'name': 'Panamera 2025',
    'price': 9696.00,
    'rating': 5.0,
    'images': [
      Assets.images.porschePanamera.path,
      Assets.images.banner3.path,
    ],
    'description':
        'Experience the raw power and precision of the Porsche Panamera RS. Engineered for adrenaline seekers and driving purists.',
    'location': 'Perumbavoor, Kerala',
    'transmission': 'Automatic',
    'fuel': 'Diesel',
    'seats': '4',
    'model': 'Panamera RS',
    'type': 'Sedan',
    'features': [
      'Apple CarPlay',
      'Android Auto',
      'Lane Assist',
      'Adaptive Cruise'
    ],
    'host': {
      'name': 'Zidhan Muhammed',
      'trips': '96',
      'image':
          'https://img.freepik.com/free-photo/close-up-portrait-handsome-smiling-young-man-white-t-shirt-blurry-outdoor-nature_176420-6305.jpg?semt=ais_se_enriched&w=740&q=80',
      'phone': '+91 7736950910',
    },
  },
  // Add more cars as needed using the same structure...
];

List<String> banners = [
  Assets.images.banner1.path,
  Assets.images.banner2.path,
  Assets.images.banner3.path,
];

List<String> topBrands = [
  'All',
  'Porsche',
  'Maserati',
  'BMW',
  'Mercedes benz',
  'Porsche',
  'Maserati',
  'BMW',
  'Mercedes benz',
];

List<String> theTitleOfTheListOfCars = [
  'Popular cars',
  'New cars',
  'Economy cars',
  'Expensive cars',
];

List<Map<String, String>> brandAndNameOfCars = [
  {
    'brand': 'Maserati',
    'name': 'Granturismo',
  },
  {
    'brand': 'PORSCHE',
    'name': '911 GTS RS',
  },
  {
    'brand': 'BMW',
    'name': 'M3 2024',
  },
  {
    'brand': 'Porsche',
    'name': 'Panamera',
  },
  {
    'brand': 'Maserati',
    'name': 'Granturismo',
  },
  {
    'brand': 'Porsche',
    'name': '911 GTS RS',
  },
  {
    'brand': 'BMW',
    'name': 'M3 2024',
  },
  {
    'brand': 'Porsche',
    'name': 'Panamera',
  }
];

List<double> prices = [
  459.00,
  528.00,
  528.00,
  439.00,
  459.00,
  528.00,
  528.00,
  439.00,
];

List<String> imagesOfCars = [
  Assets.images.maseratiGranturismo.path,
  Assets.images.porsche911GTSRS.path,
  Assets.images.bmwM3.path,
  Assets.images.porschePanamera.path,
  Assets.images.maseratiGranturismo.path,
  Assets.images.porsche911GTSRS.path,
  Assets.images.bmwM3.path,
  Assets.images.porschePanamera.path,
];

final List<Map<String, dynamic>> sampleDrivers = [
  <String, dynamic>{
    'name': 'Rajesh Kumar',
    'experience': '5 Years',
    'rating': 4.8,
    'price': 800,
    'image': 'https://randomuser.me/api/portraits/men/1.jpg',
    'category': 'Tourist',
    'languages': ['Malayalam', 'English', 'Hindi'] // Added
  },
  {
    'name': 'Suresh Menon',
    'experience': '12 Years',
    'rating': 4.9,
    'price': 1200,
    'image': 'https://randomuser.me/api/portraits/men/3.jpg',
    'category': 'Heavy',
    'languages': ['Malayalam', 'Tamil', 'Hindi'] // Added
  },
  {
    'name': 'Anil George',
    'experience': '3 Years',
    'rating': 4.5,
    'price': 500,
    'image': 'https://randomuser.me/api/portraits/men/5.jpg',
    'category': 'Taxi',
    'languages': ['Malayalam', 'English'] // Added
  },
  {
    'name': 'Deepak S',
    'experience': '8 Years',
    'rating': 4.7,
    'price': 900,
    'image': 'https://randomuser.me/api/portraits/men/7.jpg',
    'category': 'Tourist',
    'languages': ['English', 'Malayalam', 'Arabic'] // Added
  },
];

String description =
    'Experience the raw power and precision of the Porsche 911 GT3 RS, a high-performance masterpiece engineered for adrenaline seekers and driving purists. With its 4.0L naturally aspirated flat-six engine roaring at 525 HP, this track-focused beast delivers spine-tingling acceleration, razor-sharp handling, and an unforgettable symphony of exhaust notes.\nBook yours today and unleash the ultimate Porsche experience!';

String driverDescriptionTemplate(
    String name, String category, String experience) {
  return "Professional $name, a skilled $category driver with $experience of road experience. Known for exceptional driving skills, punctuality, and customer satisfaction. Book now to experience a safe and comfortable journey with $name!";
}
