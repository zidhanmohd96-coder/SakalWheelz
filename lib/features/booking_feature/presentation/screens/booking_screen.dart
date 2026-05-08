import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_button.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:car_rental_app/core/widgets/app_space.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/features/booking_feature/presentation/screens/payment_screen.dart';
import 'package:car_rental_app/features/booking_feature/data/models/booking_model.dart'
    as models;
import 'package:car_rental_app/features/booking_feature/presentation/bloc/booking_cubit.dart';
import 'package:car_rental_app/features/home_feature/data/data_source/local/sample_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> carData;

  const BookingScreen({super.key, required this.carData});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // --- STATE VARIABLES ---

  // Calendar State
  DateTime _focusedMonth = DateTime.utc(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime? _startDate;
  DateTime? _endDate;
  final List<int> _bookedDays = [5, 6, 12, 18, 19, 20]; // Mock booked days
  final RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  // Driver State
  bool _isWithDriver = false;
  Map<String, dynamic>? _selectedDriver;

  // Insurance State
  bool _isPremiumInsurance = false;

  // Promo Code State
  final TextEditingController _promoController = TextEditingController();
  bool _isPromoApplied = false;

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

    double basePrice =
        double.tryParse(widget.carData['price'].toString()) ?? 0.0;

    // Driver Cost (Use selected driver price or default $50 if none selected yet)
    double driverDailyPrice = _selectedDriver != null
        ? (double.tryParse(_selectedDriver!['price'].toString()) ?? 50.0)
        : 50.0;

    double driverTotalCost =
        _isWithDriver ? (driverDailyPrice * rentalDays) : 0.0;
    double insuranceCost = _isPremiumInsurance ? (15.0 * rentalDays) : 0.0;
    double promoDiscount = _isPromoApplied ? 0.10 : 0.0; // 10% off

    double subTotal =
        (basePrice * rentalDays) + driverTotalCost + insuranceCost;
    double totalTripPrice = subTotal - (subTotal * promoDiscount);

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

              // 4. Insurance & Protection
              const AppTitleText("Protection Plans", fontSize: 18),
              const SizedBox(height: 12),
              _buildInsuranceSelector(),

              const AppVSpace(space: Dimens.largePadding),

              // 5. Promo Code
              const AppTitleText("Apply Promo Code", fontSize: 18),
              const SizedBox(height: 12),
              _buildPromoCodeField(),

              const AppVSpace(space: Dimens.largePadding),

              // 6. Time Selection
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
                image: (widget.carData['images'] != null &&
                        (widget.carData['images'] as List).isNotEmpty)
                    ? (widget.carData['images'][0].toString().startsWith('http')
                            ? NetworkImage(widget.carData['images'][0])
                            : AssetImage(widget.carData['images'][0]))
                        as ImageProvider
                    : const AssetImage('assets/images/banner1.png'),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(DateTime.now().year, DateTime.now().month, 1),
        lastDay: DateTime.utc(DateTime.now().year + 2, 12, 31),
        focusedDay: _focusedMonth,
        rangeStartDay: _startDate,
        rangeEndDay: _endDate,
        calendarFormat: CalendarFormat.month,
        rangeSelectionMode: _rangeSelectionMode,
        onPageChanged: (focusedDay) {
          _focusedMonth = focusedDay;
        },
        onRangeSelected: (start, end, focusedDay) {
          setState(() {
            _startDate = start;
            _endDate = end;
            _focusedMonth = focusedDay;
          });
        },
        calendarStyle: CalendarStyle(
          rangeHighlightColor: AppColors.primaryColor.withOpacity(0.3),
          rangeStartDecoration: const BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          rangeEndDecoration: const BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: AppColors.primaryColor),
            shape: BoxShape.circle,
          ),
          defaultTextStyle: const TextStyle(color: Colors.white),
          weekendTextStyle: const TextStyle(color: Colors.white),
          todayTextStyle: const TextStyle(color: AppColors.primaryColor),
          outsideTextStyle: const TextStyle(color: Colors.grey),
          disabledTextStyle: const TextStyle(color: Colors.grey),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.grey),
          weekendStyle: TextStyle(color: Colors.grey),
        ),
        enabledDayPredicate: (day) {
          if (day.month == DateTime.now().month &&
              day.year == DateTime.now().year) {
            if (_bookedDays.contains(day.day)) {
              return false;
            }
          }
          return true;
        },
      ),
    );
  }

  Widget _buildInsuranceSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isPremiumInsurance = false),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: !_isPremiumInsurance
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: !_isPremiumInsurance
                        ? AppColors.primaryColor
                        : Colors.white10),
              ),
              child: Column(
                children: [
                  const Text("Basic",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Included",
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isPremiumInsurance = true),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isPremiumInsurance
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _isPremiumInsurance
                        ? AppColors.primaryColor
                        : Colors.white10),
              ),
              child: Column(
                children: [
                  const Text("Premium",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("+\$15 / day",
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCodeField() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: TextField(
              controller: _promoController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Enter Promo Code",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            if (_promoController.text.toUpperCase() == "SAKAL10") {
              setState(() => _isPromoApplied = true);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Promo Applied! 10% Off")));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid Promo Code")));
            }
          },
          child: const Text("Apply", style: TextStyle(color: Colors.white)),
        )
      ],
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
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return Container(
              height: 250,
              color: const Color(0xFF1E1E1E),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                        child: const Text('Done',
                            style: TextStyle(color: AppColors.primaryColor)),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  Expanded(
                    child: CupertinoTheme(
                      data: const CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle:
                              TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            time.hour,
                            time.minute),
                        use24hFormat: false,
                        onDateTimeChanged: (DateTime newTime) {
                          setState(() {
                            if (isPickup) {
                              _pickupTime = TimeOfDay.fromDateTime(newTime);
                            } else {
                              _dropoffTime = TimeOfDay.fromDateTime(newTime);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
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
            mainAxisSize: MainAxisSize.min,
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
              height: 85, // reduced from 94 to fit properly
              child: AppButton(
                title: "Confirm Booking",
                onPressed: () {
                  // 1. Validation
                  if (_startDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select dates!")));
                    return;
                  }

                  if (_isWithDriver && _selectedDriver == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please select a driver!")));
                    return;
                  }

                  // 2. Create a unique Booking ID
                  final String bookingId =
                      "ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

                  // Show KYC Validation Mock
                  _showKYCDialog(price, bookingId);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- LOGIC METHODS ---

  void _showKYCDialog(double price, String bookingId) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.cardColor,
            title: const Text("Identity Verification",
                style: TextStyle(color: Colors.white)),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.badge, size: 60, color: AppColors.primaryColor),
                SizedBox(height: 16),
                Text(
                    "As this is your first booking, please verify your Driving License to proceed.",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor),
                onPressed: () async {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("License Verified! Creating booking...")));

                  // Get current user
                  final user = FirebaseAuth.instance.currentUser;
                  final userId = user?.uid ?? 'anonymous';

                  // Extract car image safely
                  final images = widget.carData['images'] as List? ?? [];
                  final carImage =
                      images.isNotEmpty ? images[0].toString() : '';

                  // Extract host info
                  final host =
                      widget.carData['host'] as Map<String, dynamic>? ?? {};

                  // Calculate days
                  final endDate =
                      _endDate ?? _startDate!.add(const Duration(days: 1));
                  final rentalDays = endDate.difference(_startDate!).inDays + 1;

                  // Build the booking model
                  final booking = models.BookingModel(
                    id: '', // Will be set by Firestore
                    userId: userId,
                    carId: widget.carData['id']?.toString() ?? '',
                    carBrand: widget.carData['brand']?.toString() ?? '',
                    carName: widget.carData['name']?.toString() ?? '',
                    carImage: carImage,
                    carType: widget.carData['type']?.toString() ?? '',
                    carTransmission:
                        widget.carData['transmission']?.toString() ?? '',
                    hostName: host['name']?.toString() ?? '',
                    hostPhone: host['phone']?.toString() ?? '',
                    startDate: _startDate!,
                    endDate: endDate,
                    pickupTime: _pickupTime.format(this.context),
                    dropoffTime: _dropoffTime.format(this.context),
                    pickupLocation: _pickupLocation,
                    dropoffLocation: _dropoffLocation,
                    hasDriver: _isWithDriver,
                    driverName: _selectedDriver?['name']?.toString(),
                    driverCost: _isWithDriver && _selectedDriver != null
                        ? (double.tryParse(
                                    _selectedDriver!['price'].toString()) ??
                                0.0) *
                            rentalDays
                        : 0.0,
                    hasPremiumInsurance: _isPremiumInsurance,
                    insuranceCost:
                        _isPremiumInsurance ? 15.0 * rentalDays : 0.0,
                    promoCode: _isPromoApplied ? _promoController.text : null,
                    promoDiscount: _isPromoApplied ? 0.10 : 0.0,
                    basePricePerDay:
                        double.tryParse(widget.carData['price'].toString()) ??
                            0.0,
                    rentalDays: rentalDays,
                    totalPrice: price,
                    status: 'Active',
                    createdAt: DateTime.now(),
                  );

                  // Navigate to Payment Screen instead of directly saving to Firestore
                  if (mounted) {
                    Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          booking: booking,
                          carData: widget.carData,
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Upload & Verify",
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        });
  }

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
