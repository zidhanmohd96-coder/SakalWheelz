import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/widgets/app_button.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class BecomeHostScreen extends StatefulWidget {
  const BecomeHostScreen({super.key});

  @override
  State<BecomeHostScreen> createState() => _BecomeHostScreenState();
}

class _BecomeHostScreenState extends State<BecomeHostScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: Text("Become a Host\nStep ${_currentStep + 1} of 3",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step Progress Bar
          Row(
            children: List.generate(
                3,
                (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index <= _currentStep
                              ? Colors.blueAccent
                              : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildCurrentStep(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: TextButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text("Back",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    title: _currentStep == 2
                        ? "Complete Registration"
                        : "Continue",
                    onPressed: () {
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Host Application Submitted!")));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _step1Personal();
      case 1:
        return _step2KYC();
      case 2:
        return _step3Bank();
      default:
        return const SizedBox();
    }
  }

  // STEP 1: Personal Info
  Widget _step1Personal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBanner(
            "Why become a Host?", Icons.auto_awesome, Colors.blueAccent, [
          "Earn ₹30,000+ monthly",
          "List unlimited vehicles",
          "Full control over pricing"
        ]),
        const SizedBox(height: 24),
        const Text("Personal Information",
            style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTextField("Full Name", "Ex: John Doe"),
        const SizedBox(height: 16),
        _buildTextField("Phone Number", "+91 9876543210", isPhone: true),
        const SizedBox(height: 16),
        _buildTextField("City", "Mumbai"),
        const SizedBox(height: 16),
        _buildTextField("Full Address", "Enter your address"),
      ],
    );
  }

  // STEP 2: KYC
  Widget _step2KYC() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSimpleBanner(
            "Secure Verification",
            "Your documents are encrypted and stored securely.",
            Icons.security,
            Colors.green),
        const SizedBox(height: 24),
        const Text("KYC Verification",
            style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTextField("Aadhaar Number", "1234 5678 9012"),
        const SizedBox(height: 16),
        _buildTextField("PAN Number (Optional)", "ABCDE1234F"),
        const SizedBox(height: 24),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file, color: Colors.grey, size: 30),
                SizedBox(height: 8),
                Text("Upload Aadhaar (Front & Back)",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        )
      ],
    );
  }

  // STEP 3: Bank Details
  Widget _step3Bank() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSimpleBanner(
            "Instant Payouts",
            "Get your earnings directly in your bank account.",
            Icons.credit_card,
            Colors.purpleAccent),
        const SizedBox(height: 24),
        const Text("Bank Account Details",
            style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTextField("Bank Account Number", "Enter account number"),
        const SizedBox(height: 16),
        _buildTextField("IFSC Code", "SBIN0001234"),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, {bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(color: Colors.white),
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: AppColors.cardColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade800)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade800)),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner(
      String title, IconData icon, Color color, List<String> points) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(title,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16))
          ]),
          const SizedBox(height: 12),
          ...points.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Icon(Icons.check, size: 16, color: color),
                const SizedBox(width: 8),
                Text(p, style: const TextStyle(color: Colors.white70))
              ]))),
        ],
      ),
    );
  }

  Widget _buildSimpleBanner(
      String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20)),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(color: Colors.white70, fontSize: 13))
              ])),
        ],
      ),
    );
  }
}
