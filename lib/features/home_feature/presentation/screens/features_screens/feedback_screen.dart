import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/widgets/base_layout.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  Future<void> _sendEmail() async {
    final subject = Uri.encodeComponent(_subjectController.text);
    final body = Uri.encodeComponent(_messageController.text);

    // ----------- PRIMARY: Gmail compose in browser -----------
    // final emailUrl =
    //     "https://mail.google.com/mail/?view=cm&fs=1&to=sakalwheels@gmail.com"
    //     "&su=$subject&body=$body";

    // final gmailUri = Uri.parse(emailUrl);

    // if (await canLaunchUrl(gmailUri)) {
    //   await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
    //   return;
    // }

    // ----------- FALLBACK: WhatsApp message -----------
    const whatsappNumber = "918547806553"; // change this to macha’s number
    final whatsappUrl = Uri.parse("https://wa.me/$whatsappNumber?text=$body");

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      return;
    }

    // ----------- FINAL FALLBACK: Error message -----------
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't open Email or WhatsApp"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Feedback",
            style: TextStyle(color: AppColors.whiteColor)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          children: [
            const Text(
              "We'd love to hear from you!",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor),
            ),
            const SizedBox(height: 8),
            const Text(
              "Send us your bugs, feature requests, or just say hi.",
              style: TextStyle(color: AppColors.grayColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: "Subject",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Your Message",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _sendEmail,
                icon: const Icon(Icons.send),
                label: const Text("Send to SakalWheels"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
