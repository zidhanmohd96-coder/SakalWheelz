import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_button.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:car_rental_app/core/widgets/app_space.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/features/booking_feature/presentation/screens/booking_success_screen.dart';
import 'package:car_rental_app/features/home_feature/data/data_source/local/sample_data.dart'; // Ensure sampleDrivers is here
import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> carData;

  const BookingScreen({super.key, required this.carData});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // --- STATE VARIABLES ---

  // Calendar State
  DateTime _focusedMonth = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  final List<int> _bookedDays = [5, 6, 12, 18, 19, 20]; // Mock booked days

  // Driver State
  bool _isWithDriver = false;
  Map<String, dynamic>? _selectedDriver;

  // Time State
  TimeOfDay _pickupTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _dropoffTime = const TimeOfDay(hour: 10, minute: 0);

  // Location State
  String _pickupLocation = "Kochi International Airport";
  String _dropoffLocation = "Lulu Mall, Edappally";

  // Available Locations for Dropdown
  final List<String> _keralaLocations = [
    "Kochi International Airport",
    "Lulu Mall, Edappally",
    "Technopark, Trivandrum",
    "Calicut Beach",
    "Munnar Town",
    "Alleppey Houseboat Terminal",
    "Varkala Cliff",
    "MG Road, Kochi"
  ];

  @override
  Widget build(BuildContext context) {
    // --- Calculations ---
    int rentalDays = 1;
    if (_startDate != null && _endDate != null) {
      rentalDays = _endDate!.difference(_startDate!).inDays + 1;
    }

    double basePrice = (widget.carData['price'] is int)
        ? (widget.carData['price'] as int).toDouble()
        : (widget.carData['price'] as double);

    // Driver Cost (Use selected driver price or default $50 if none selected yet)
    double driverDailyPrice = _selectedDriver != null
        ? (_selectedDriver!['price'] is int
            ? (_selectedDriver!['price'] as int).toDouble()
            : _selectedDriver!['price'])
        : 50.0;

    double driverTotalCost =
        _isWithDriver ? (driverDailyPrice * rentalDays) : 0.0;
    double totalTripPrice = (basePrice * rentalDays) + driverTotalCost;

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
              // 1. Car Summary
              _buildCarSummaryCard(),
              const AppVSpace(space: Dimens.largePadding),

              // 2. Calendar
              const AppTitleText("Select Dates", fontSize: 18),
              const SizedBox(height: 12),
              _buildCustomCalendar(),
              const SizedBox(height: 8),
              _buildLegend(),

              const AppVSpace(space: Dimens.largePadding),

              // 3. Driver Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppTitleText("Driver Required?", fontSize: 18),
                  Switch(
                    value: _isWithDriver,
                    activeThumbColor: AppColors.primaryColor,
                    onChanged: (val) {
                      setState(() {
                        _isWithDriver = val;
                        if (!val) _selectedDriver = null; // Clear if turned off
                      });
                    },
                  ),
                ],
              ),
              if (_isWithDriver) ...[
                const SizedBox(height: 12),
                _buildDriverSelector(),
              ],

              const AppVSpace(space: Dimens.largePadding),

              // 4. Time Selection
              const AppTitleText("Time Schedule", fontSize: 18),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildTimePickerBox(
                          "Pickup Time", _pickupTime, true)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildTimePickerBox(
                          "Drop-off Time", _dropoffTime, false)),
                ],
              ),

              const AppVSpace(space: Dimens.largePadding),

              // 5. Locations
              const AppTitleText("Location Details", fontSize: 18),
              const SizedBox(height: 16),
              _buildLocationInput(
                  "Pickup Location", Icons.my_location, _pickupLocation, true),
              const SizedBox(height: 12),
              _buildLocationInput("Drop-off Location",
                  Icons.location_on_outlined, _dropoffLocation, false),

              const AppVSpace(space: 160), // Bottom padding
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomPaymentBar(totalTripPrice, rentalDays),
    );
  }

  // --- WIDGETS ---

  Widget _buildCarSummaryCard() {
    // Same as before
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage((widget.carData['images'] != null &&
                        (widget.carData['images'] as List).isNotEmpty)
                    ? widget.carData['images'][0]
                    : 'assets/images/banner1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.carData['brand']} ${widget.carData['name']}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "${widget.carData['type']} • ${widget.carData['transmission']}",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCustomCalendar() {
    // Logic for days in displayed month
    final int daysInMonth =
        DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final int firstWeekday =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;
    final List<String> weekDays = ["M", "T", "W", "T", "F", "S", "S"];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Month Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                // Simple Month Year Display
                "${_focusedMonth.month == 1 ? "Jan" : _focusedMonth.month == 2 ? "Feb" : _focusedMonth.month == 3 ? "Mar" : _focusedMonth.month == 4 ? "Apr" : _focusedMonth.month == 5 ? "May" : _focusedMonth.month == 6 ? "Jun" : _focusedMonth.month == 7 ? "Jul" : _focusedMonth.month == 8 ? "Aug" : _focusedMonth.month == 9 ? "Sep" : _focusedMonth.month == 10 ? "Oct" : _focusedMonth.month == 11 ? "Nov" : "Dec"} ${_focusedMonth.year}",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(
                            _focusedMonth.year, _focusedMonth.month - 1);
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(
                            _focusedMonth.year, _focusedMonth.month + 1);
                      });
                    },
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          // Weekdays
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays
                .map((day) => SizedBox(
                    width: 30,
                    child: Center(
                        child: Text(day,
                            style: TextStyle(color: Colors.grey.shade600)))))
                .toList(),
          ),
          const SizedBox(height: 10),
          // Grid
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
              if (index < firstWeekday - 1) return const SizedBox();

              final int day = index - (firstWeekday - 1) + 1;
              final DateTime currentDate =
                  DateTime(_focusedMonth.year, _focusedMonth.month, day);

              // Only simulate booked days for current month/year to avoid complexity
              final bool isBooked = _bookedDays.contains(day) &&
                  _focusedMonth.month == DateTime.now().month &&
                  _focusedMonth.year == DateTime.now().year;

              final bool isSelected = _isDateSelected(currentDate);

              return GestureDetector(
                onTap: isBooked ? null : () => _onDateTapped(currentDate),
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

  Widget _buildDriverSelector() {
    return SizedBox(
      height: 140, // Height for driver cards
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sampleDrivers.length,
        separatorBuilder: (c, i) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final driver = sampleDrivers[index];
          final isSelected = _selectedDriver == driver;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDriver = driver;
              });
            },
            child: Container(
              width: 120,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primaryColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(driver['image']),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    driver['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "\$${driver['price']}/day",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 10),
                      Text(" ${driver['rating']}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10)),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimePickerBox(String label, TimeOfDay time, bool isPickup) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primaryColor,
                  onPrimary: Colors.black,
                  surface: Color(0xFF1E1E1E),
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            if (isPickup) {
              _pickupTime = picked;
            } else {
              _dropoffTime = picked;
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(isPickup ? Icons.access_time_filled : Icons.access_time,
                color: isPickup ? AppColors.primaryColor : Colors.white),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInput(
      String label, IconData icon, String value, bool isPickup) {
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
              InkWell(
                onTap: () => _showLocationSelector(isPickup),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text("Edit",
                          style: TextStyle(
                              color: AppColors.primaryColor, fontSize: 12)),
                    ],
                  ),
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
        borderRadius: BorderRadius.circular(
          Dimens.corners * 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      margin: const EdgeInsets.all(Dimens.largePadding),
      child: Row(
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
          const SizedBox(width: 40),
          Expanded(
            child: SizedBox(
              height: 94,
              child: AppButton(
                title: "Confirm Booking",
                onPressed: () {
                  // 1. Validation
                  if (_startDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select dates!")));
                    return;
                  }

                  // 2. Create a unique Booking ID
                  final String bookingId =
                      "ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

                  // 3. SAVE THE DATA! (This connects it to the Booking Tab)
                  // We add it to index 0 so it appears at the top of the list
                  myBookings.insert(
                      0,
                      BookingModel(
                        id: bookingId,
                        car: widget.carData,
                        startDate: _startDate!,
                        endDate: _endDate ??
                            _startDate!.add(const Duration(days: 1)),
                        status: 'Active',
                        totalPrice:
                            price, // Ensure this variable name matches your calculation
                      ));

                  // 4. Navigate to Success Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingSuccessScreen(
                        carData: widget.carData,
                        bookingId: bookingId,
                        startDate: _startDate!,
                        endDate: _endDate ??
                            _startDate!.add(const Duration(days: 1)),
                        totalPrice: price,
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- LOGIC METHODS ---

  void _showLocationSelector(bool isPickup) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            children: [
              const AppTitleText("Select Location", fontSize: 18),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _keralaLocations.length,
                  separatorBuilder: (c, i) =>
                      const Divider(color: Colors.white10),
                  itemBuilder: (context, index) {
                    final loc = _keralaLocations[index];
                    return ListTile(
                      leading:
                          const Icon(Icons.location_on, color: Colors.grey),
                      title: Text(loc,
                          style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        setState(() {
                          if (isPickup) {
                            _pickupLocation = loc;
                          } else {
                            _dropoffLocation = loc;
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onDateTapped(DateTime date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = date;
        _endDate = null;
      } else if (_startDate != null && date.isAfter(_startDate!)) {
        _endDate = date;
      } else {
        _startDate = date;
        _endDate = null;
      }
    });
  }

  bool _isDateSelected(DateTime date) {
    if (_startDate == null) return false;

    if (_endDate == null) {
      return DateUtils.isSameDay(date, _startDate);
    }

    return (DateUtils.isSameDay(date, _startDate) ||
        DateUtils.isSameDay(date, _endDate) ||
        (date.isAfter(_startDate!) && date.isBefore(_endDate!)));
  }

  // Legend Helper
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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }
}
