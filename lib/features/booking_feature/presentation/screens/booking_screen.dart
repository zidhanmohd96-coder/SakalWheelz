import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_button.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:car_rental_app/core/widgets/app_space.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> carData;

  const BookingScreen({super.key, required this.carData});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // State Variables
  DateTime _focusedDay = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isWithDriver = false;
  String _pickupTime = "10:00 AM";

  // Mock "Booked" dates to simulate real-world availability
  final List<int> _bookedDays = [5, 6, 12, 18, 19, 20];

  @override
  Widget build(BuildContext context) {
    // Calculate Total Price
    // Default to 1 day if no range selected
    int rentalDays = 1;
    if (_startDate != null && _endDate != null) {
      rentalDays = _endDate!.difference(_startDate!).inDays + 1;
    }

    // Base Price
    double basePrice = (widget.carData['price'] is int)
        ? (widget.carData['price'] as int).toDouble()
        : (widget.carData['price'] as double);

    // Driver Cost ($50 per day extra)
    double driverCost = _isWithDriver ? (50.0 * rentalDays) : 0.0;

    double totalPrice = (basePrice * rentalDays) + driverCost;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            const Text("Book Your Ride", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CAR SUMMARY CARD
              _buildCarSummaryCard(),
              const AppVSpace(space: Dimens.largePadding),

              // 2. CALENDAR SECTION
              const AppTitleText("Select Dates", fontSize: 18),
              const SizedBox(height: 12),
              _buildCustomCalendar(),
              const SizedBox(height: 8),
              _buildLegend(),

              const AppVSpace(space: Dimens.largePadding),

              // 3. RENTAL OPTIONS (Driver / Time)
              const AppTitleText("Rental Options", fontSize: 18),
              const SizedBox(height: 16),
              _buildRentalOptions(),

              const AppVSpace(space: Dimens.largePadding),

              // 4. LOCATIONS
              const AppTitleText("Location Details", fontSize: 18),
              const SizedBox(height: 16),
              _buildLocationInput("Pickup Location", Icons.my_location,
                  "Kochi International Airport"),
              const SizedBox(height: 12),
              _buildLocationInput("Drop-off Location",
                  Icons.location_on_outlined, "Lulu Mall, Edappally"),

              const AppVSpace(space: 100), // Bottom padding for button
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomPaymentBar(totalPrice, rentalDays),
    );
  }

  // --- WIDGETS ---

  Widget _buildCarSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage((widget.carData['images'] != null &&
                        (widget.carData['images'] as List).isNotEmpty)
                    ? widget.carData['images'][0]
                    : 'assets/images/banner1.png'), // Fallback
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.carData['brand']} ${widget.carData['name']}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${widget.carData['type']} • ${widget.carData['transmission']}",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCustomCalendar() {
    // A simplified custom calendar for the current month
    // In a real app, use 'table_calendar' package for complex logic

    // Days in current month logic (Simplified for demo)
    final int daysInMonth = 31;
    final int firstWeekday =
        DateTime(DateTime.now().year, DateTime.now().month, 1).weekday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("December 2025",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Row(
                children: [
                  Icon(Icons.chevron_left, color: Colors.grey),
                  const SizedBox(width: 16),
                  Icon(Icons.chevron_right, color: Colors.white),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          // Days Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["M", "T", "W", "T", "F", "S", "S"]
                .map((day) => SizedBox(
                    width: 30,
                    child: Center(
                        child: Text(day,
                            style: TextStyle(color: Colors.grey.shade600)))))
                .toList(),
          ),
          const SizedBox(height: 12),
          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + (firstWeekday - 1),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1)
                return const SizedBox(); // Empty slots

              final int day = index - (firstWeekday - 1) + 1;
              final bool isBooked = _bookedDays.contains(day);
              final bool isSelected = _isDateSelected(day);

              return GestureDetector(
                onTap: isBooked ? null : () => _onDateTapped(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                        : (isBooked
                            ? Colors.white.withOpacity(0.05)
                            : Colors.transparent),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isBooked
                                ? Colors.transparent
                                : Colors.grey.shade800),
                  ),
                  child: Center(
                    child: Text(
                      "$day",
                      style: TextStyle(
                        color: isBooked
                            ? Colors.grey.shade700
                            : (isSelected ? Colors.black : Colors.white),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        decoration:
                            isBooked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _legendItem(AppColors.primaryColor, "Selected"),
        const SizedBox(width: 12),
        _legendItem(Colors.grey.shade700, "Booked"),
        const SizedBox(width: 12),
        _legendItem(Colors.white, "Available"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildRentalOptions() {
    return Row(
      children: [
        // Driver Toggle
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isWithDriver = !_isWithDriver;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: _isWithDriver
                    ? AppColors.primaryColor.withOpacity(0.2)
                    : AppColors.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _isWithDriver
                        ? AppColors.primaryColor
                        : Colors.transparent),
              ),
              child: Column(
                children: [
                  Icon(Icons.person,
                      color: _isWithDriver
                          ? AppColors.primaryColor
                          : Colors.white),
                  const SizedBox(height: 8),
                  const Text("With Driver",
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  Text("+ \$50/day",
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Time Picker (Static for demo)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.access_time, color: Colors.white),
                const SizedBox(height: 8),
                const Text("Pickup Time",
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                Text(_pickupTime,
                    style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInput(String label, IconData icon, String value) {
    return Row(
      children: [
        Column(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 20),
            if (label.contains("Pickup"))
              Container(width: 2, height: 30, color: Colors.grey.shade800),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(value,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14)),
                    const Text("Edit",
                        style: TextStyle(
                            color: AppColors.primaryColor, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPaymentBar(double price, int days) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Total for $days Days",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                "\$${price.toStringAsFixed(0)}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            width: 160,
            child: AppButton(
              title: "Confirm Booking",
              onPressed: () {
                // Add booking logic or navigation to Success Screen
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text("Booking Confirmed for ${widget.carData['brand']}!"),
                  backgroundColor: Colors.green,
                ));
              },
            ),
          )
        ],
      ),
    );
  }

  // Logic Helpers
  void _onDateTapped(int day) {
    setState(() {
      DateTime tappedDate =
          DateTime(DateTime.now().year, DateTime.now().month, day);

      if (_startDate == null || (_startDate != null && _endDate != null)) {
        // Start fresh selection
        _startDate = tappedDate;
        _endDate = null;
      } else if (_startDate != null && tappedDate.isAfter(_startDate!)) {
        // Select End Date
        _endDate = tappedDate;
      } else {
        // Reset if tapping before start date
        _startDate = tappedDate;
        _endDate = null;
      }
    });
  }

  bool _isDateSelected(int day) {
    if (_startDate == null) return false;
    DateTime checkDate =
        DateTime(DateTime.now().year, DateTime.now().month, day);

    // Single date selected
    if (_endDate == null) {
      return checkDate.isAtSameMomentAs(_startDate!);
    }

    // Range selected
    return (checkDate.isAtSameMomentAs(_startDate!) ||
        checkDate.isAtSameMomentAs(_endDate!) ||
        (checkDate.isAfter(_startDate!) && checkDate.isBefore(_endDate!)));
  }
}
