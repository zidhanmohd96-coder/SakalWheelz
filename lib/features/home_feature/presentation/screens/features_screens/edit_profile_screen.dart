import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/widgets/base_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add intl to pubspec.yaml for date formatting

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetching = true;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController =
      TextEditingController(); // Read only usually
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // 1. Fetch Existing Data
  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;

          _nameController.text = data['full_name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone_number'] ?? '';
          _addressController.text = data['address'] ?? '';
          _stateController.text = data['state'] ?? '';
          _locationController.text = data['location'] ?? ''; // e.g. City/Area
          _selectedGender = data['gender'];

          // Handle Timestamp for DOB
          if (data['dob'] != null) {
            Timestamp t = data['dob'];
            DateTime date = t.toDate();
            _dobController.text = DateFormat('dd-MM-yyyy').format(date);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  // 2. Save Data to Firestore
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Parse DOB back to Timestamp
        DateTime? dobDate;
        if (_dobController.text.isNotEmpty) {
          dobDate = DateFormat('dd-MM-yyyy').parse(_dobController.text);
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'full_name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'address': _addressController.text.trim(),
          'state': _stateController.text.trim(),
          'location': _locationController.text.trim(),
          'gender': _selectedGender,
          'dob': dobDate != null ? Timestamp.fromDate(dobDate) : null,
          'updated_at': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Updated Successfully! ✅")),
          );
          Navigator.pop(context); // Go back to Profile Tab
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Date Picker Helper
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryColor,
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    setState(() {
      _dobController.text = DateFormat('dd-MM-yyyy').format(picked!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }

    return BaseLayout(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Personal Details"),
              _buildTextField("Full Name", _nameController, Icons.person),
              _buildTextField("Email Address", _emailController, Icons.email),

              // Phone is usually read-only as it's the login ID
              _buildTextField(
                "Phone Number",
                _phoneController,
                Icons.phone,
                readOnly: true,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: IgnorePointer(
                        child: _buildTextField(
                          "Date of Birth",
                          _dobController,
                          Icons.calendar_today,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildGenderDropdown()),
                ],
              ),

              const SizedBox(height: 30),
              _buildSectionHeader("Location Details"),

              _buildTextField(
                "Address / Street",
                _addressController,
                Icons.home,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      "City / Location",
                      _locationController,
                      Icons.location_on,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      "State",
                      _stateController,
                      Icons.map,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save Changes",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // 🛠️ FIXED: Added spacing and removed conflicting labelText
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. The Label ABOVE the box
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            color: AppColors.whiteColor, // Or white if your background is dark
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8), //  Space to prevent overlap
        // 2. The Input Box
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          style: const TextStyle(color: AppColors.blackColor),
          validator: (val) => val!.isEmpty && !readOnly ? "Required" : null,
          decoration: InputDecoration(
            // Use HINT text, not LABEL text inside
            hintText: "Enter $label",
            hintStyle: TextStyle(color: AppColors.grayColor.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: AppColors.grayColor),
            filled: true,
            fillColor: readOnly ? Colors.white : AppColors.whiteColor,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ), // Taller box
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16), // Space between fields
      ],
    );
  }

  // 🛠️ FIXED: Gender Dropdown matching the new style
  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gender",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.whiteColor,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedGender,
          items: _genders.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                    color: AppColors.blackColor,
                    backgroundColor: AppColors.whiteColor),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },
          decoration: InputDecoration(
            hintText: "Select",
            prefixIcon: const Icon(Icons.people, color: AppColors.grayColor),
            filled: true,
            fillColor: AppColors.whiteColor,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
