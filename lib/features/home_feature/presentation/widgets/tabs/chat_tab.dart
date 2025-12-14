import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/features/home_feature/data/data_source/local/sample_data.dart';
import 'package:car_rental_app/features/home_feature/presentation/screens/features_screens/chat_detail_screen.dart';
import 'package:flutter/material.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _syncChatsWithBookings();
  }

  // --- LOGIC: Sync Bookings to Chats ---
  void _syncChatsWithBookings() {
    // 1. Loop through all active/completed bookings
    final activeBookings =
        myBookings.where((b) => b.status != 'Cancelled').toList();

    for (var booking in activeBookings) {
      if (booking.car['host'] != null) {
        final host = booking.car['host'];

        // 2. Check if a chat already exists for this Host
        // We use Name as ID for simplicity in this demo
        final bool chatExists = myChats.any((c) => c.name == host['name']);

        if (!chatExists) {
          // 3. Create new Chat Entry if not found
          myChats.add(ChatModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: host['name'],
            image: host['image'] ??
                "https://randomuser.me/api/portraits/lego/1.jpg",
            role: 'Host',
            isOnline: true, // Mock status
            unreadCount: 1, // Welcome message is unread
            lastMessageText:
                "Thank you for booking! Let me know if you have questions.",
            lastMessageTime: DateTime.now(),
            messages: [
              {
                "isMe": false,
                "text":
                    "Thank you for booking! Let me know if you have questions.",
                "time": DateTime.now(),
                "status": "read"
              }
            ],
          ));
        }
      }
    }

    // Refresh UI
    if (mounted) setState(() {});
  }

  void _markAsRead(ChatModel chat) {
    setState(() {
      chat.unreadCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter chats based on search
    final displayChats = _searchQuery.isEmpty
        ? myChats
        : myChats
            .where((c) => c.name.toLowerCase().contains(_searchQuery))
            .toList();

    // Sort by latest message
    displayChats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: AppTitleText('Messages', fontSize: 28),
        ),
      ),
      body: Column(
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
                hintText: "Search conversations...",
                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: AppColors.cardColor,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: AppColors.primaryColor)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Chat List
          Expanded(
            child: displayChats.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    itemCount: displayChats.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildChatTile(displayChats[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 60, color: Colors.grey.shade800),
          const SizedBox(height: 16),
          Text("No active chats",
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text("Book a car to start messaging!",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChatTile(ChatModel chat) {
    final bool hasUnread = chat.unreadCount > 0;

    return GestureDetector(
      onTap: () async {
        _markAsRead(chat);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(chat: chat),
          ),
        );
        // Refresh state when coming back (to update last message preview)
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: hasUnread
              ? Border.all(color: AppColors.primaryColor.withOpacity(0.3))
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color:
                        hasUnread ? AppColors.primaryColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(chat.image),
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.cardColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Text(
                        _formatTime(chat.lastMessageTime),
                        style: TextStyle(
                            color: hasUnread
                                ? AppColors.primaryColor
                                : Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: hasUnread
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessageText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: hasUnread
                                  ? Colors.white
                                  : Colors.grey.shade500,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 14),
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              chat.unreadCount.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays == 0) {
      final hour =
          time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
      final period = time.hour >= 12 ? 'PM' : 'AM';
      final minute = time.minute.toString().padLeft(2, '0');
      return "$hour:$minute $period";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else {
      return "${time.day}/${time.month}";
    }
  }
}
