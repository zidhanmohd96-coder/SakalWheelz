import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class HostHomeScreen extends StatelessWidget {
  const HostHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title:
            const Text("Host Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.garage, size: 80, color: Colors.blueAccent),
            SizedBox(height: 20),
            Text("No Vehicles Listed",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 10),
            Text("Add your first car to start earning.",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add),
        label: const Text("Add Vehicle"),
      ),
    );
  }
}
