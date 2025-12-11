import 'package:flutter/material.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Column(
          children: [
            Text('Chat Tab'),
            SizedBox(height: 10),
            Text('This is where chat messages will be displayed.'),
          ],
        ),
      ),
    );
  }
}
