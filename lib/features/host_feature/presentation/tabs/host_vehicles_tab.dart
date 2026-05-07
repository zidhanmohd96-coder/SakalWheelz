import 'dart:io';
import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/core/network/firebase_collections.dart';
import 'package:car_rental_app/features/car_feature/data/models/car_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';

class HostVehiclesTab extends StatefulWidget {
  const HostVehiclesTab({super.key});

  @override
  State<HostVehiclesTab> createState() => _HostVehiclesTabState();
}

class _HostVehiclesTabState extends State<HostVehiclesTab> {
  String _hostName = '';

  @override
  void initState() {
    super.initState();
    _loadHostName();
  }

  Future<void> _loadHostName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _hostName = doc.data()?['full_name'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("My Vehicles", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVehicleDialog(context),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Vehicle",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _hostName.isEmpty
          ? _buildShimmer()
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(FirebaseCollections.cars)
                  .where('host.name', isEqualTo: _hostName)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmer();
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(Dimens.largePadding),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final car = CarModel.fromJson(
                        docs[index].data() as Map<String, dynamic>,
                        docs[index].id);
                    return _buildVehicleCard(car, index);
                  },
                );
              },
            ),
    );
  }

  Widget _buildVehicleCard(CarModel car, int index) {
    final isAsset = car.images.isNotEmpty && !car.images[0].startsWith('http');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // Car Image
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: car.images.isNotEmpty
                  ? isAsset
                      ? Image.asset(car.images[0],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildImagePlaceholder())
                      : Image.network(car.images[0],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildImagePlaceholder())
                  : _buildImagePlaceholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTitleText("${car.brand} ${car.name}",
                          fontSize: 16),
                      const SizedBox(height: 4),
                      Text(
                        "\$${car.price.toStringAsFixed(0)}/day • ${car.type}",
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Available",
                    style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade900,
      child:
          const Center(child: Icon(Icons.directions_car, size: 50, color: Colors.grey)),
    );
  }

  void _showAddVehicleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return _AddVehicleBottomSheet(hostName: _hostName);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined,
              size: 60, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text("No vehicles listed",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          const SizedBox(height: 8),
          Text("Tap + to add your first vehicle",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(Dimens.largePadding),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade800,
          highlightColor: Colors.grey.shade700,
          child: Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}

class _AddVehicleBottomSheet extends StatefulWidget {
  final String hostName;
  const _AddVehicleBottomSheet({required this.hostName});

  @override
  State<_AddVehicleBottomSheet> createState() => _AddVehicleBottomSheetState();
}

class _AddVehicleBottomSheetState extends State<_AddVehicleBottomSheet> {
  final brandController = TextEditingController();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();
  String selectedType = 'Sedan';
  String selectedFuel = 'Petrol';
  String selectedTransmission = 'Automatic';
  
  final List<File> _selectedImages = [];
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((img) => File(img.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages() async {
    List<String> downloadUrls = [];
    final storageRef = FirebaseStorage.instance.ref().child('car_images');
    
    for (var file in _selectedImages) {
      final fileName = const Uuid().v4();
      final uploadTask = await storageRef.child('$fileName.jpg').putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      downloadUrls.add(url);
    }
    return downloadUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const AppTitleText("Add New Vehicle", fontSize: 22),
            const SizedBox(height: 24),

            // Image Picker Section
            const Text("Car Photos", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryColor, width: 2, style: BorderStyle.solid),
                      ),
                      child: const Center(child: Icon(Icons.add_a_photo, color: AppColors.primaryColor, size: 32)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ..._selectedImages.asMap().entries.map((entry) {
                    int idx = entry.key;
                    File file = entry.value;
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 16,
                          child: GestureDetector(
                            onTap: () => _removeImage(idx),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildTextField(brandController, "Brand", "e.g., Toyota"),
            const SizedBox(height: 12),
            _buildTextField(nameController, "Model Name", "e.g., Fortuner"),
            const SizedBox(height: 12),
            _buildTextField(priceController, "Price per Day (\$)", "e.g., 500", keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField(locationController, "Location", "e.g., Kochi, Kerala"),
            const SizedBox(height: 16),

            const Text("Vehicle Type", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Sedan', 'SUV', 'Luxury', 'Sport', 'Hatchback']
                  .map((type) => ChoiceChip(
                        label: Text(type),
                        selected: selectedType == type,
                        selectedColor: AppColors.primaryColor,
                        onSelected: (v) => setState(() => selectedType = type),
                        labelStyle: TextStyle(color: selectedType == type ? Colors.black : Colors.white),
                        backgroundColor: AppColors.cardColor,
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildDropdown('Fuel', selectedFuel, ['Petrol', 'Diesel', 'Electric', 'Hybrid'], (v) => setState(() => selectedFuel = v!))),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown('Transmission', selectedTransmission, ['Automatic', 'Manual'], (v) => setState(() => selectedTransmission = v!))),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isUploading ? null : () async {
                  if (brandController.text.isEmpty || nameController.text.isEmpty || priceController.text.isEmpty || _selectedImages.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields and add at least one photo")));
                    return;
                  }

                  setState(() => _isUploading = true);

                  try {
                    List<String> imageUrls = await _uploadImages();

                    await FirebaseFirestore.instance.collection(FirebaseCollections.cars).add({
                      'brand': brandController.text.trim(),
                      'name': nameController.text.trim(),
                      'price': double.tryParse(priceController.text) ?? 0,
                      'rating': 5.0,
                      'images': imageUrls,
                      'description': 'A beautiful ${brandController.text} ${nameController.text} available for rent.',
                      'location': locationController.text.isNotEmpty ? locationController.text.trim() : 'Kerala',
                      'transmission': selectedTransmission,
                      'fuel': selectedFuel,
                      'seats': selectedType == 'SUV' ? '7' : '5',
                      'model': nameController.text.trim(),
                      'type': selectedType,
                      'features': ['Bluetooth', 'GPS', 'AC'],
                      'host': {
                        'name': widget.hostName,
                        'trips': '0',
                        'image': '',
                        'phone': FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
                      },
                    });

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vehicle added successfully!"), backgroundColor: Colors.green));
                    }
                  } catch (e) {
                    setState(() => _isUploading = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
                child: _isUploading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text("Add Vehicle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        fillColor: AppColors.cardColor,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryColor)),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: AppColors.cardColor,
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.white),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
