import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/features/driver_feature/presentation/bloc/driver_cubit.dart';
import 'package:car_rental_app/features/driver_feature/presentation/screens/driver_details_screen.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/car_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_rental_app/features/home_feature/data/data_source/local/sample_data.dart';
import 'package:car_rental_app/features/car_feature/presentation/bloc/car_cubit.dart';

enum SearchType { vehicle, driver }

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();

  // State Variables
  SearchType _selectedType = SearchType.vehicle;
  String _searchQuery = "";

  // --- VEHICLE FILTER STATES ---
  RangeValues _vehiclePriceRange = const RangeValues(0, 10000);
  String? _selectedTransmission; // 'Automatic', 'Manual'
  String? _selectedFuelType; // 'Petrol', 'Diesel', 'Electric'
  String? _searchLocation;
  String? _selectedCarType;
  String? _selectedBrand;
  String _selectedSort = 'Recommended';

  // --- DRIVER FILTER STATES ---
  RangeValues _driverPriceRange = const RangeValues(0, 5000);
  String? _selectedDriverCategory; // 'Tourist', 'Heavy', 'Taxi'
  double _minDriverRating = 0.0;

  @override
  void initState() {
    super.initState();
  }

  void _runSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      isScrollControlled: true, // Allows sheet to grow with content
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Filter ${_selectedType == SearchType.vehicle ? 'Vehicles' : 'Drivers'}",
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.whiteColor),
                      ),
                      TextButton(
                        onPressed: () {
                          // Reset Logic
                          setModalState(() {
                            if (_selectedType == SearchType.vehicle) {
                              _vehiclePriceRange = const RangeValues(0, 10000);
                              _selectedTransmission = null;
                              _selectedFuelType = null;
                              _searchLocation = null;
                              _selectedCarType = null;
                              _selectedBrand = null;
                              _selectedSort = 'Recommended';
                            } else {
                              _driverPriceRange = const RangeValues(0, 5000);
                              _selectedDriverCategory = null;
                              _minDriverRating = 0.0;
                            }
                          });
                        },
                        child: const Text("Reset",
                            style: TextStyle(color: Colors.redAccent)),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // DYNAMIC CONTENT BASED ON TYPE
                  if (_selectedType == SearchType.vehicle)
                    _buildVehicleFilters(setModalState)
                  else
                    _buildDriverFilters(setModalState),

                  const SizedBox(height: 32),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {}); // Trigger rebuild to apply filters
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Apply Filters",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- VEHICLE FILTER UI ---
  Widget _buildVehicleFilters(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sort By
        _buildFilterLabel("Sort By"),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedSort,
          dropdownColor: AppColors.cardColor,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            filled: true,
            fillColor: AppColors.cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          items: ['Recommended', 'Price: Low to High', 'Price: High to Low', 'Rating: High to Low'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setModalState(() => _selectedSort = v!),
        ),
        const SizedBox(height: 24),

        // Location
        _buildFilterLabel("Location"),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: _searchLocation),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter location",
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: AppColors.cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onChanged: (v) => setModalState(() => _searchLocation = v),
        ),
        const SizedBox(height: 24),

        // Price Range
        _buildFilterLabel("Price Range (Per Day)"),
        RangeSlider(
          values: _vehiclePriceRange,
          min: 0,
          max: 10000,
          divisions: 20,
          activeColor: AppColors.primaryColor,
          inactiveColor: AppColors.lightGrayColor,
          labels: RangeLabels(
            "₹${_vehiclePriceRange.start.round()}",
            "₹${_vehiclePriceRange.end.round()}",
          ),
          onChanged: (RangeValues values) {
            setModalState(() => _vehiclePriceRange = values);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("₹${_vehiclePriceRange.start.round()}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            Text("₹${_vehiclePriceRange.end.round()}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),

        const SizedBox(height: 24),

        // Brand
        _buildFilterLabel("Brand"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: ['Toyota', 'BMW', 'Audi', 'Mercedes', 'Hyundai', 'Mahindra'].map((type) {
            final isSelected = _selectedBrand == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              selectedColor: AppColors.primaryColor,
              labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.whiteColor),
              backgroundColor: AppColors.cardColor,
              side: BorderSide.none,
              onSelected: (bool selected) => setModalState(() => _selectedBrand = selected ? type : null),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Car Type
        _buildFilterLabel("Car Type"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: ['Sedan', 'SUV', 'Luxury', 'Sport', 'Hatchback'].map((type) {
            final isSelected = _selectedCarType == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              selectedColor: AppColors.primaryColor,
              labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.whiteColor),
              backgroundColor: AppColors.cardColor,
              side: BorderSide.none,
              onSelected: (bool selected) => setModalState(() => _selectedCarType = selected ? type : null),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Transmission
        _buildFilterLabel("Transmission"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: ['Automatic', 'Manual'].map((type) {
            final isSelected = _selectedTransmission == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              selectedColor: AppColors.primaryColor,
              labelStyle:
                  TextStyle(color: isSelected ? Colors.white : Colors.white),
              backgroundColor: AppColors.cardColor,
              side: BorderSide.none,
              onSelected: (bool selected) {
                setModalState(
                    () => _selectedTransmission = selected ? type : null);
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Fuel Type
        _buildFilterLabel("Fuel Type"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: ['Petrol', 'Diesel', 'Electric'].map((type) {
            final isSelected = _selectedFuelType == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              selectedColor: AppColors.primaryColor,
              labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.whiteColor),
              backgroundColor: AppColors.cardColor,
              side: BorderSide.none,
              onSelected: (bool selected) {
                setModalState(() => _selectedFuelType = selected ? type : null);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- DRIVER FILTER UI ---
  Widget _buildDriverFilters(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price Range
        _buildFilterLabel("Price Range (Per Day)"),
        RangeSlider(
          values: _driverPriceRange,
          min: 0,
          max: 5000,
          divisions: 10,
          activeColor: AppColors.primaryColor,
          inactiveColor: AppColors.lightGrayColor,
          labels: RangeLabels(
            "₹${_driverPriceRange.start.round()}",
            "₹${_driverPriceRange.end.round()}",
          ),
          onChanged: (RangeValues values) {
            setModalState(() => _driverPriceRange = values);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("₹${_driverPriceRange.start.round()}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            Text("₹${_driverPriceRange.end.round()}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),

        const SizedBox(height: 24),

        // Category
        _buildFilterLabel("Category"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: ['Tourist', 'Heavy', 'Taxi'].map((cat) {
            final isSelected = _selectedDriverCategory == cat;
            return ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: AppColors.primaryColor,
              labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.whiteColor),
              backgroundColor: AppColors.cardColor,
              onSelected: (bool selected) {
                setModalState(
                    () => _selectedDriverCategory = selected ? cat : null);
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Rating
        _buildFilterLabel("Minimum Rating"),
        const SizedBox(height: 8),
        Row(
          children: [3.0, 4.0, 4.5].map((rating) {
            final isSelected = _minDriverRating == rating;
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("\$rating+"),
                    const SizedBox(width: 4),
                    Icon(Icons.star,
                        size: 14,
                        color: isSelected ? Colors.white : Colors.amber),
                  ],
                ),
                selected: isSelected,
                selectedColor: AppColors.primaryColor,
                labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.whiteColor),
                backgroundColor: AppColors.cardColor,
                onSelected: (bool selected) {
                  setModalState(
                      () => _minDriverRating = selected ? rating : 0.0);
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontWeight: FontWeight.w600, color: AppColors.whiteColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(
              backgroundColor: AppColors.backgroundColor,
              elevation: 0,
              scrolledUnderElevation: 0, // 🔥 IMPORTANT
              surfaceTintColor: Colors.transparent,
              title: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: AppTitleText('Search Vehicles', fontSize: 28),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ---------------- 1. SEARCH BAR & FILTER ----------------
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _runSearch,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: _selectedType == SearchType.vehicle
                                ? "Search cars..."
                                : "Search drivers...",
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: AppColors.cardColor,
                            prefixIcon: const Icon(Icons.search,
                                color: AppColors.grayColor),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: _showFilterBottomSheet,
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.tune, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ---------------- 2. TYPE SELECTOR (VEHICLE / DRIVER) ----------------
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor, // Light background for toggle
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    child: Row(
                      children: [
                        _buildTypeButton("Vehicles", SearchType.vehicle),
                        _buildTypeButton("Drivers", SearchType.driver),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------------- 3. RESULTS LIST ----------------
                  Expanded(
                    child: _selectedType == SearchType.vehicle
                        ? _buildCarList()
                        : _buildDriverList(),
                  ),
                ],
              ),
            )));
  }

  Widget _buildTypeButton(String title, SearchType type) {
    final bool isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.whiteColor : AppColors.grayColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarList() {
    return BlocBuilder<CarCubit, CarState>(
      builder: (context, state) {
        if (state is CarLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CarError) {
          return const Center(
              child: Text("Error loading cars",
                  style: TextStyle(color: Colors.red)));
        } else if (state is CarLoaded) {
          final cars = state.cars.where((car) {
            final name = "${car.brand} ${car.name}".toLowerCase();
            final matchesQuery = name.contains(_searchQuery.toLowerCase());
            final matchesPrice = car.price >= _vehiclePriceRange.start &&
                car.price <= _vehiclePriceRange.end;
            final matchesFuel = _selectedFuelType == null ||
                car.fuel.toLowerCase() == _selectedFuelType!.toLowerCase();
            final matchesTrans = _selectedTransmission == null ||
                car.transmission.toLowerCase() ==
                    _selectedTransmission!.toLowerCase();
            final matchesType = _selectedCarType == null || car.type.toLowerCase() == _selectedCarType!.toLowerCase();
            final matchesBrand = _selectedBrand == null || car.brand.toLowerCase() == _selectedBrand!.toLowerCase();
            final matchesLocation = _searchLocation == null || _searchLocation!.isEmpty || car.location.toLowerCase().contains(_searchLocation!.toLowerCase());

            return matchesQuery && matchesPrice && matchesFuel && matchesTrans && matchesType && matchesBrand && matchesLocation;
          }).toList();

          if (_selectedSort == 'Price: Low to High') {
            cars.sort((a, b) => a.price.compareTo(b.price));
          } else if (_selectedSort == 'Price: High to Low') {
            cars.sort((a, b) => b.price.compareTo(a.price));
          } else if (_selectedSort == 'Rating: High to Low') {
            cars.sort((a, b) => b.rating.compareTo(a.rating));
          }

          if (cars.isEmpty) return _buildEmptyState();

          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: CarCard(
                  carData: cars[index].toJson(),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDriverList() {
    return BlocBuilder<DriverCubit, DriverState>(
      builder: (context, state) {
        if (state is DriverLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DriverError) {
          return const Center(
              child: Text("Error loading drivers",
                  style: TextStyle(color: Colors.red)));
        } else if (state is DriverLoaded) {
          final filteredDrivers = state.drivers.where((driver) {
            final name = driver.name.toLowerCase();
            final price = driver.price;
            final category = driver.category;
            final rating = driver.rating;

            final matchesQuery = name.contains(_searchQuery.toLowerCase());
            final matchesPrice = price >= _driverPriceRange.start &&
                price <= _driverPriceRange.end;
            final matchesCategory = _selectedDriverCategory == null ||
                category == _selectedDriverCategory;
            final matchesRating = rating >= _minDriverRating;

            return matchesQuery &&
                matchesPrice &&
                matchesCategory &&
                matchesRating;
          }).toList();

          if (filteredDrivers.isEmpty) return _buildEmptyState();

          return ListView.builder(
            itemCount: filteredDrivers.length,
            itemBuilder: (context, index) {
              final driver = filteredDrivers[index];

              return GestureDetector(
                onTap: () {
                  // Navigate to Details Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DriverDetailsScreen(driver: driver.toJson()),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.9)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          driver.image,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.person,
                                      color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.whiteColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${driver.experience} Experience • ${driver.category}",
                              style: const TextStyle(
                                  color: AppColors.whiteColor, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              driver.languages.join(', '),
                              style: const TextStyle(
                                  color: AppColors.whiteColor, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  driver.rating.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "₹${driver.price}",
                            style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const Text(
                            "/day",
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text(
            "No results found",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your filters or search query",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
