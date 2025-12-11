import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/features/driver_feature/presentation/screens/driver_details_screen.dart';
import 'package:car_rental_app/features/home_feature/presentation/widgets/car_card.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/features/home_feature/data/data_source/local/sample_data.dart';

// ---------------- YOUR SAMPLE DATA ----------------

// ---------------------------------------------------

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
  List<int> _filteredCarIndexes = [];
  List<int> _filteredDriverIndexes = [];

  // --- VEHICLE FILTER STATES ---
  RangeValues _vehiclePriceRange = const RangeValues(0, 10000);
  String? _selectedTransmission; // 'Automatic', 'Manual'
  String? _selectedFuelType; // 'Petrol', 'Diesel', 'EV'

  // --- DRIVER FILTER STATES ---
  RangeValues _driverPriceRange = const RangeValues(0, 5000);
  String? _selectedDriverCategory; // 'Tourist', 'Heavy', 'Taxi'
  double _minDriverRating = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize with all data
    _filteredCarIndexes = List.generate(brandAndNameOfCars.length, (i) => i);
    _filteredDriverIndexes = List.generate(sampleDrivers.length, (i) => i);
  }

  void _runSearch(String query) {
    setState(() {
      if (_selectedType == SearchType.vehicle) {
        _filteredCarIndexes = [];
        for (int i = 0; i < brandAndNameOfCars.length; i++) {
          final car = brandAndNameOfCars[i];
          final price = prices[i];
          final name = "${car['brand']} ${car['name']}".toLowerCase();

          final matchesQuery = name.contains(query.toLowerCase());
          final matchesPrice = price >= _vehiclePriceRange.start &&
              price <= _vehiclePriceRange.end;

          // Note: In a real app, you would check car['transmission'] and car['fuel'] here.
          // Since our sample data is simple, we only filter by Price and Query currently.

          if (matchesQuery && matchesPrice) {
            _filteredCarIndexes.add(i);
          }
        }
      } else {
        _filteredDriverIndexes = [];
        for (int i = 0; i < sampleDrivers.length; i++) {
          final driver = sampleDrivers[i];
          final name = driver['name'].toString().toLowerCase();
          final price = (driver['price'] as int).toDouble();
          final category = driver['category'];
          final rating = (driver['rating'] as double);

          final matchesQuery = name.contains(query.toLowerCase());
          final matchesPrice = price >= _driverPriceRange.start &&
              price <= _driverPriceRange.end;
          final matchesCategory = _selectedDriverCategory == null ||
              category == _selectedDriverCategory;
          final matchesRating = rating >= _minDriverRating;

          if (matchesQuery &&
              matchesPrice &&
              matchesCategory &&
              matchesRating) {
            _filteredDriverIndexes.add(i);
          }
        }
      }
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
                        _runSearch(_searchController.text);
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
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("₹${_vehiclePriceRange.end.round()}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
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
        _buildFilterLabel("Daily Rate Range"),
        RangeSlider(
          values: _driverPriceRange,
          min: 0,
          max: 5000,
          divisions: 20,
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
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("₹${_driverPriceRange.end.round()}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    Text("$rating+"),
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
      child: Padding(
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
                    decoration: InputDecoration(
                      hintText: _selectedType == SearchType.vehicle
                          ? "Search cars..."
                          : "Search drivers...",
                      filled: true,
                      fillColor: AppColors.cardColor,
                      prefixIcon:
                          const Icon(Icons.search, color: AppColors.grayColor),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
      ),
    );
  }

  Widget _buildTypeButton(String title, SearchType type) {
    final bool isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            _runSearch(_searchController.text); // Re-run search for new type
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
    if (_filteredCarIndexes.isEmpty) return _buildEmptyState();

    return ListView.builder(
      itemCount: carsList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: CarCard(
            carData: carsList[index],
          ),
        );
      },
    );
  }

  Widget _buildDriverList() {
    if (_filteredDriverIndexes.isEmpty) return _buildEmptyState();

    return ListView.builder(
      itemCount: _filteredDriverIndexes.length,
      itemBuilder: (context, index) {
        final i = _filteredDriverIndexes[index];
        final driver = sampleDrivers[i];

        return GestureDetector(
          onTap: () {
            // Navigate to Details Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DriverDetailsScreen(driver: driver),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.primaryColor.withOpacity(0.9)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    driver['image'],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[200],
                        child: const Icon(Icons.person, color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.whiteColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${driver['experience']} Experience • ${driver['category']}",
                        style: const TextStyle(
                            color: AppColors.whiteColor, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (driver['languages'] as List<String>?)?.join(', ') ??
                            'No info',
                        style: const TextStyle(
                            color: AppColors.whiteColor, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            driver['rating'].toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
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
                      "₹${driver['price']}",
                      style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const Text(
                      "/day",
                      style:
                          TextStyle(color: AppColors.grayColor, fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("View",
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 60, color: AppColors.primaryColor),
          const SizedBox(height: 16),
          Text(
            "No ${_selectedType == SearchType.vehicle ? 'vehicles' : 'drivers'} found.",
            style: const TextStyle(fontSize: 16, color: AppColors.grayColor),
          ),
        ],
      ),
    );
  }
}
