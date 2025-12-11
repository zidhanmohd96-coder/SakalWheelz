import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/widgets/base_layout.dart';
import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      "question": "How do I become a Host?",
      "answer":
          "Go to your Profile tab and click on 'Become a Host'. Complete the KYC process, upload your vehicle details (RC, Insurance), and once verified, you can start listing your cars."
    },
    {
      "question": "What documents are required to rent?",
      "answer":
          "You need a valid Driving License, Aadhaar Card, and PAN Card. All documents must be verified in the 'My Documents' section before your trip starts."
    },
    {
      "question": "Is fuel included in the price?",
      "answer":
          "No, fuel is not included. The car is provided with a certain fuel level, and you must return it with the same level to avoid extra charges."
    },
    {
      "question": "Can I cancel my booking?",
      "answer":
          "Yes, you can cancel your booking from the 'My Bookings' section. Cancellation charges may apply depending on how close to the trip start time you cancel."
    },
    {
      "question": "What if I return the car late?",
      "answer":
          "Late returns are charged on an hourly basis. If the delay exceeds 4 hours, a full day's rental fee may be charged."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("FAQ", style: TextStyle(color: AppColors.whiteColor)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: BaseLayout(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                title: Text(
                  faqs[index]['question']!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.whiteColor),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      faqs[index]['answer']!,
                      style: const TextStyle(
                          color: AppColors.grayColor, height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
