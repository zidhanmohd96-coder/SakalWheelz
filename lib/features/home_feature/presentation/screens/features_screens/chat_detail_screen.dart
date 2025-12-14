import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:car_rental_app/features/home_feature/data/data_source/local/sample_data.dart'; // Import ChatModel
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatModel chat; // Accept the real data model

  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  void _sendMessage() {
    if (_controller.text.isEmpty) return;

    final String text = _controller.text.trim();
    final DateTime now = DateTime.now();

    setState(() {
      // 1. Add to the Global Model's message list
      widget.chat.messages
          .add({"isMe": true, "text": text, "time": now, "status": "sent"});

      // 2. Update Global Last Message preview
      widget.chat.lastMessageText = text;
      widget.chat.lastMessageTime = now;

      _controller.clear();
    });

    _scrollToBottom();
    _simulateAutoReply();
  }

  void _simulateAutoReply() async {
    setState(() => _isTyping = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    const String reply = "Okay, noted! See you soon.";
    final DateTime now = DateTime.now();

    setState(() {
      _isTyping = false;

      // Update Global Model
      widget.chat.messages
          .add({"isMe": false, "text": reply, "time": now, "status": "read"});
      widget.chat.lastMessageText = reply;
      widget.chat.lastMessageTime = now;
      // We don't increase unread count here because the user is currently looking at the screen
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chat.image),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.name,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  _isTyping
                      ? "Typing..."
                      : (widget.chat.isOnline ? "Online" : "Offline"),
                  style: TextStyle(
                    fontSize: 12,
                    color: _isTyping
                        ? AppColors.primaryColor
                        : (widget.chat.isOnline
                            ? Colors.greenAccent
                            : Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.backgroundColor,
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount:
                    widget.chat.messages.length, // Read directly from model
                itemBuilder: (context, index) {
                  return _buildMessageBubble(widget.chat.messages[index]);
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Message...",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.black, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryColor : const Color(0xFF333333),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg['text'],
              style: TextStyle(
                color: isMe ? Colors.black : Colors.white,
                fontSize: 15,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('hh:mm a').format(msg['time']),
                  style: TextStyle(
                    color: isMe ? Colors.black54 : Colors.grey.shade400,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, size: 12, color: Colors.black54),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
