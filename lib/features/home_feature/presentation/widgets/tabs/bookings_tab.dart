import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_button.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/features/home_feature/data/data_source/local/sample_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingTab extends StatefulWidget {
  const BookingTab({super.key});

  @override
  State<BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<BookingTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = "";
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // --- LOGIC: Cancel Booking ---
  void _cancelBooking(BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Cancel Booking?",
            style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to cancel this trip? This action cannot be undone.",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text("No, Keep it", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                myBookings.remove(booking);
                myBookings.add(BookingModel(
                  id: booking.id,
                  car: booking.car,
                  startDate: booking.startDate,
                  endDate: booking.endDate,
                  status: 'Cancelled',
                  totalPrice: booking.totalPrice,
                ));
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Booking Cancelled"),
                    backgroundColor: Colors.red),
              );
            },
            child:
                const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- LOGIC: View Ticket ---
  void _showTicket(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 600,
        decoration: const BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const AppTitleText("E-Ticket", fontSize: 22),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text("ID: ${booking.id}",
                      style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  const SizedBox(height: 20),
                  const Icon(Icons.qr_code_2, size: 120, color: Colors.black),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.black12),
                  const SizedBox(height: 10),
                  _buildTicketRow(
                      "Car", "${booking.car['brand']} ${booking.car['name']}"),
                  const SizedBox(height: 8),
                  _buildTicketRow("Start",
                      DateFormat('dd MMM, hh:mm a').format(booking.startDate)),
                  const SizedBox(height: 8),
                  _buildTicketRow("End",
                      DateFormat('dd MMM, hh:mm a').format(booking.endDate)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8)),
                    child: _buildTicketRow("Total Paid",
                        "\$${booking.totalPrice.toStringAsFixed(0)}",
                        isBold: true, color: Colors.green.shade800),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: AppButton(
                  title: "Download PDF",
                  onPressed: () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.black54, fontSize: 13)),
        Text(value,
            style: TextStyle(
                color: color ?? Colors.black,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                fontSize: 15)),
      ],
    );
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: AppTitleText('My Trips', fontSize: 28),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.toLowerCase()),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search by Car or ID...",
                    hintStyle:
                        TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: AppColors.cardColor,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.primaryColor, width: 1)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryColor,
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorWeight: 3,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'History'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(statusFilter: 'Active'),
          _buildBookingList(statusFilter: 'Completed'),
        ],
      ),
    );
  }

  Widget _buildBookingList({required String statusFilter}) {
    final filteredList = myBookings.where((b) {
      bool statusMatch;
      if (statusFilter == 'Active') {
        statusMatch = b.status == 'Active';
      } else {
        statusMatch = b.status == 'Completed' || b.status == 'Cancelled';
      }

      final searchMatch =
          b.car['name'].toString().toLowerCase().contains(_searchQuery) ||
              b.id.toLowerCase().contains(_searchQuery) ||
              b.car['brand'].toString().toLowerCase().contains(_searchQuery);

      return statusMatch && searchMatch;
    }).toList();

    filteredList.sort((a, b) => b.startDate.compareTo(a.startDate));

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.airplane_ticket_outlined,
                size: 80, color: Colors.grey.shade800),
            const SizedBox(height: 16),
            Text(
              "No ${statusFilter.toLowerCase()} trips found",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primaryColor,
      backgroundColor: AppColors.cardColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: filteredList.length,
        separatorBuilder: (c, i) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          return _buildBookingCard(filteredList[index]);
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final List<dynamic> images = booking.car['images'] ?? [];
    final String imagePath =
        images.isNotEmpty ? images[0].toString() : 'assets/images/banner1.png';

    // Status Logic
    Color statusColor;
    String statusText = booking.status;
    IconData statusIcon;

    switch (booking.status) {
      case 'Active':
        statusColor = Colors.green;
        statusIcon = Icons.schedule;
        break;
      case 'Completed':
        statusColor = AppColors.primaryColor;
        statusIcon = Icons.check_circle;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    // Time Text Logic
    String timeText = "";
    if (booking.status == 'Active') {
      final days = booking.startDate.difference(DateTime.now()).inDays;
      if (days == 0) {
        timeText = "Starts Today";
      } else if (days > 0)
        timeText = "In $days days";
      else
        timeText = "In Progress";
    } else {
      timeText = DateFormat('MMM dd').format(booking.endDate);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // --- CARD HEADER ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date Range
                Row(
                  children: [
                    Icon(Icons.calendar_month,
                        size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Text(
                      "${DateFormat('MMM dd').format(booking.startDate)} - ${DateFormat('MMM dd').format(booking.endDate)}",
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText.toUpperCase(),
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- CARD BODY ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${booking.car['brand']} ${booking.car['name']}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "ID: ${booking.id}",
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$${booking.totalPrice.toStringAsFixed(0)}",
                            style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          if (booking.status == 'Active')
                            Text(
                              timeText,
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- CARD FOOTER (Buttons) ---
          if (booking.status != 'Cancelled')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  if (booking.status == 'Active') ...[
                    Expanded(
                        child: _buildActionButton(
                            "Cancel",
                            Colors.red.withOpacity(0.1),
                            Colors.red,
                            () => _cancelBooking(booking))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildActionButton(
                            "View Ticket",
                            AppColors.primaryColor,
                            Colors.black,
                            () => _showTicket(booking))),
                  ] else if (booking.status == 'Completed') ...[
                    Expanded(child: _buildOutlineButton("Invoice", () {})),
                    const SizedBox(width: 12),
                    Expanded(child: _buildOutlineButton("Rate Trip", () {})),
                  ]
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String title, Color bg, Color text, VoidCallback onTap) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: text,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildOutlineButton(String title, VoidCallback onTap) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade700),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(title, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}
