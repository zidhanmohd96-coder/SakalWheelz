import 'package:flutter/material.dart';

class BookingsTab extends StatelessWidget {
  const BookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          child: const Column(
            children: [
              Text('Booking History Tab'),
              SizedBox(height: 10),
              Text('Here you can see your past rentals.')
            ],
          ),
        ),
      ),
    );
  }
}
