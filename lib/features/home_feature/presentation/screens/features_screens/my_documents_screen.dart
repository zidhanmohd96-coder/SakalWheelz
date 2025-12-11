import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/widgets/base_layout.dart';
import 'package:flutter/material.dart';

class MyDocumentsScreen extends StatefulWidget {
  const MyDocumentsScreen({super.key});

  @override
  State<MyDocumentsScreen> createState() => _MyDocumentsScreenState();
}

class _MyDocumentsScreenState extends State<MyDocumentsScreen> {
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _dlController = TextEditingController();
  final TextEditingController _dobController =
      TextEditingController(text: "10 March 2007"); // Default from image

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("My Documents",
            style: TextStyle(
                color: AppColors.whiteColor, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: Container(
        color: Colors.transparent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Document Verification",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor),
              ),
              const SizedBox(height: 4),
              const Text(
                "(For faster processing of booking)",
                style: TextStyle(fontSize: 14, color: AppColors.grayColor),
              ),
              const SizedBox(height: 24),

              // 1. Date of Birth Section
              _buildLabel("Date of Birth as per Pan"),
              Row(
                children: [
                  Expanded(child: _buildInputBox(_dobController)),
                  const SizedBox(width: 12),
                  _buildActionButton("Save", onTap: () {}),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Pan Number Section
              _buildLabel("Pan Number*"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildInputBox(_panController),
                  const SizedBox(height: 12),
                  _buildActionButton("Validate", onTap: () {}),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Driving License Section
              _buildLabel("Driving License"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildInputBox(_dlController),
                  const SizedBox(height: 12),
                  _buildActionButton("Validate", onTap: () {}),
                ],
              ),
              const SizedBox(height: 20),

              // DL Uploads
              Row(
                children: [
                  Expanded(child: _buildUploadBox("Upload DL Front Side")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildUploadBox("Upload DL Back Side")),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Aadhaar Card Section
              _buildLabel("Aadhaar Card"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildInputBox(TextEditingController(),
                      hint:
                          "Enter Aadhaar Number"), // New controller for Aadhaar
                  const SizedBox(height: 12),
                  _buildActionButton("DigiLocker", onTap: () {}, width: 140),
                ],
              ),
              const SizedBox(height: 20),

              // Aadhaar Uploads
              Row(
                children: [
                  Expanded(child: _buildUploadBox("Upload Aadhaar Front Side")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildUploadBox("Upload Aadhaar Back Side")),
                ],
              ),
              const SizedBox(height: 20),

              _buildUploadBox(
                  "Upload Selfie (Optional)"), // Placeholder based on general flows

              const SizedBox(height: 30),
              const Text(
                "Note: You need to validate DL and UID after making payment to confirm your booking.",
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets based on Screenshot ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text,
          style: const TextStyle(fontSize: 14, color: AppColors.whiteColor)),
    );
  }

  Widget _buildInputBox(TextEditingController controller, {String? hint}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Light gray background
        borderRadius: BorderRadius.circular(30), // Rounded pill shape
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          contentPadding: const EdgeInsets.only(bottom: 4),
        ),
        style: const TextStyle(
            fontWeight: FontWeight.w600, color: AppColors.blackColor),
      ),
    );
  }

  Widget _buildActionButton(String text,
      {required VoidCallback onTap, double width = 120}) {
    return SizedBox(
      width: width,
      height: 45,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primaryColor, // Dark Navy/Black from screenshot
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildUploadBox(String label) {
    return Column(
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.grey.shade400,
                style: BorderStyle
                    .solid), // Dashed border requires external package, using solid grey for now
          ),
          child: const Center(
            child: Icon(Icons.file_upload_outlined,
                size: 30, color: AppColors.grayColor),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.grayColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
