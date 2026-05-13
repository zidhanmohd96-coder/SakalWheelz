import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/features/booking_feature/data/models/booking_model.dart';
import 'package:car_rental_app/features/booking_feature/presentation/bloc/booking_cubit.dart';
import 'package:car_rental_app/features/booking_feature/presentation/screens/booking_success_screen.dart';
import 'package:car_rental_app/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentScreen extends StatefulWidget {
  final BookingModel booking;
  final Map<String, dynamic> carData;

  const PaymentScreen({
    super.key,
    required this.booking,
    required this.carData,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'Credit Card';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Payment", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Amount",
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                      Text("\$${widget.booking.totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 32),
                  _buildSummaryRow("Vehicle", widget.booking.carName),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                      "Rental Days", "${widget.booking.rentalDays} Days"),
                  if (widget.booking.hasDriver) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow("Driver Status", "Included"),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 32),

            const AppTitleText("Payment Method", fontSize: 18),
            const SizedBox(height: 16),

            // Payment Methods
            _buildPaymentMethodTile("Credit Card", Icons.credit_card),
            const SizedBox(height: 12),
            _buildPaymentMethodTile("PayPal", Icons.paypal),
            const SizedBox(height: 12),
            _buildPaymentMethodTile("Google Pay", Icons.g_mobiledata),

            if (_selectedMethod == 'Credit Card') ...[
              const SizedBox(height: 24),
              const AppTitleText("Card Details", fontSize: 18),
              const SizedBox(height: 16),
              _buildTextField("Cardholder Name", "John Doe"),
              const SizedBox(height: 16),
              _buildTextField("Card Number", "•••• •••• •••• 4242"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField("Expiry Date", "MM/YY")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField("CVV", "123", obscure: true)),
                ],
              ),
            ],

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isProcessing ? null : _processPayment,
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("Pay Now",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPaymentMethodTile(String title, IconData icon) {
    final isSelected = _selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.white10,
              width: 2),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primaryColor : Colors.white,
                size: 28),
            const SizedBox(width: 16),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600))),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            obscureText: obscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment gateway delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Save to Firestore via BookingCubit
    final cubit = context.read<BookingCubit>();
    final firestoreId = await cubit.createBooking(widget.booking);

    if (mounted && firestoreId != null) {
      // Trigger Local Notification
      await NotificationService.showBookingSuccessNotification(
        bookingId: firestoreId.substring(0, 8).toUpperCase(),
        carName: widget.booking.carName,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSuccessScreen(
            carData: widget.carData,
            bookingId: firestoreId.substring(0, 8).toUpperCase(),
            startDate: widget.booking.startDate,
            endDate: widget.booking.endDate,
            totalPrice: widget.booking.totalPrice,
          ),
        ),
      );
    } else {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create booking!")));
    }
  }
}
