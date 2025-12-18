import 'package:car_rental_app/core/managers/role_manager.dart';
import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/widgets/app_button.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BecomeDriverScreen extends StatefulWidget {
  const BecomeDriverScreen({super.key});
  @override
  State<BecomeDriverScreen> createState() => _BecomeDriverScreenState();
}

class _BecomeDriverScreenState extends State<BecomeDriverScreen> {
  int _currentStep = 0;

  // -- State Variables for Step 3 --
  final List<String> _selectedServices = [];
  final List<String> _selectedLanguages = ["English"]; // Default selection

  // Data Lists
  final List<Map<String, dynamic>> _serviceTypes = [
    {"title": "Car Driver", "icon": Icons.directions_car},
    {"title": "Tourist Driver", "icon": Icons.map},
    {"title": "Wedding Driver", "icon": Icons.favorite_border},
    {"title": "Outstation", "icon": Icons.flight_takeoff},
    {"title": "Personal Driver", "icon": Icons.person_outline},
  ];

  final List<String> _languages = [
    "Hindi",
    "English",
    "Marathi",
    "Tamil",
    "Telugu",
    "Kannada",
    "Gujarati"
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            }),
        title: Column(
          children: [
            const Text("Become a Driver",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text("Step ${_currentStep + 1} of 3",
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // -- Progress Bar --
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? AppColors.primaryColor
                            : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
              ),
            ),
          ),

          // -- Scrollable Content --
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentStep(),
            ),
          ),

          // -- Bottom Buttons --
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(children: [
              if (_currentStep > 0)
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _currentStep--),
                    child: const Text("Back",
                        style: TextStyle(color: Colors.white70)),
                  ),
                ),
              Expanded(
                flex: 2,
                child: AppButton(
                  title:
                      _currentStep == 2 ? "Complete Registration" : "Continue",
                  onPressed: () async {
                    // Make async
                    if (_currentStep < 2) {
                      setState(() => _currentStep++);
                    } else {
                      // ✅ 1. SHOW LOADING (Optional but good UX)
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Submitting Application...")));

                      // ✅ 2. UPDATE FIRESTORE
                      try {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .update({
                            'is_driver_verified':
                                true, // Setting to true for demo (In real app, might be 'pending')
                            'driver_details': {
                              // You can add the form data here if you stored it in variables
                              'submitted_at': FieldValue.serverTimestamp(),
                            }
                          });

                          // ✅ 3. UPDATE LOCAL STATE & SWITCH MODE
                          RoleManager().registerAsDriver();

                          // ✅ 4. CLOSE SCREEN
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Welcome to Driver Mode!")));
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    }
                  },
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // -- Step Switcher --
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _step1Personal();
      case 1:
        return _step2License();
      case 2:
        return _step3Profile();
      default:
        return const SizedBox();
    }
  }

  // ===========================================================================
  // STEP 1: Personal Information
  // ===========================================================================
  Widget _step1Personal() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Value Prop Card (Orange)
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryColor
              .withOpacity(0.15), // Dark mode friendly orange bg
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              const Text("Earn on Your Schedule",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ]),
            const SizedBox(height: 16),
            _buildCheckItem("Flexible working hours"),
            _buildCheckItem("Instant payouts"),
            _buildCheckItem("Earn tips & bonuses"),
          ],
        ),
      ),
      const SizedBox(height: 32),
      const Text("Personal Information",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 20),
      _buildTextField("Full Name", "Sakal Driver"),
      const SizedBox(height: 16),
      _buildTextField("Phone Number", "+91 9876543210"),
      const SizedBox(height: 16),
      _buildTextField("City", "Kochi"),
      const SizedBox(height: 16),
      _buildTextField("Years of Experience", "Eg: 3"),
    ]);
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(children: [
        const Icon(Icons.check, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white70)),
      ]),
    );
  }

  // ===========================================================================
  // STEP 2: License & KYC
  // ===========================================================================
  Widget _step2License() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Secure Banner (Green)
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(children: [
          Icon(Icons.security, color: Colors.greenAccent, size: 28),
          SizedBox(width: 16),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Secure Verification",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              SizedBox(height: 4),
              Text("Your documents are verified using DigiLocker instantly.",
                  style: TextStyle(color: Colors.white60, fontSize: 12)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 30),
      const Text("License & KYC",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 20),
      _buildTextField("Driving License Number", "MH0120190001234"),
      const SizedBox(height: 16),
      _buildTextField("License Expiry Date", "mm/dd/yyyy", isDate: true),
      const SizedBox(height: 24),

      // Upload Box 1
      _buildUploadBox(
          "Upload Driving License (Front & Back)", "JPG, PNG up to 5MB"),
      // Upload Box 2
      _buildUploadBox(
          "Upload Profile Photo", "Clear face photo for verification"),
    ]);
  }

  Widget _buildUploadBox(String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        // Simulating Dotted Border with dashed-looking color or standard border
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined,
              size: 32, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          const SizedBox(height: 4),
          Text(sub,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }

  // ===========================================================================
  // STEP 3: Driver Profile Setup
  // ===========================================================================
  Widget _step3Profile() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Driver Profile Setup",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 20),
      const Text("Type of Driving Services",
          style: TextStyle(color: Colors.white70)),
      const SizedBox(height: 12),

      // Grid of Services
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _serviceTypes.length,
        itemBuilder: (context, index) {
          final service = _serviceTypes[index];
          final isSelected = _selectedServices.contains(service["title"]);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedServices.remove(service["title"]);
                } else {
                  _selectedServices.add(service["title"]);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withOpacity(0.2)
                    : AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.transparent,
                    width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(service["icon"],
                      color:
                          isSelected ? AppColors.primaryColor : Colors.white70),
                  Text(service["title"],
                      style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.white,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        },
      ),

      const SizedBox(height: 24),
      const Text("Languages Spoken", style: TextStyle(color: Colors.white70)),
      const SizedBox(height: 12),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _languages.map((lang) {
          final isSelected = _selectedLanguages.contains(lang);
          return FilterChip(
            label: Text(lang),
            selected: isSelected,
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  _selectedLanguages.add(lang);
                } else {
                  _selectedLanguages.remove(lang);
                }
              });
            },
            backgroundColor: AppColors.cardColor,
            selectedColor: AppColors.primaryColor,
            labelStyle:
                TextStyle(color: isSelected ? Colors.black : Colors.white),
            checkmarkColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide.none,
          );
        }).toList(),
      ),

      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(child: _buildTextField("Hourly Rate (₹)", "150")),
          const SizedBox(width: 16),
          Expanded(child: _buildTextField("Daily Rate (₹)", "1000")),
        ],
      ),
    ]);
  }

  // -- Reusable Text Field --
  Widget _buildTextField(String label, String hint, {bool isDate = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade600),
              suffixIcon: isDate
                  ? const Icon(Icons.calendar_today,
                      size: 18, color: Colors.white70)
                  : null,
              filled: true,
              fillColor: AppColors.cardColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none))),
    ]);
  }
}
