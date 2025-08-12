import 'package:flutter/material.dart';
import '../../domain/entities/chat.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback? onTap;

  const ChatTile({super.key, required this.chat, this.onTap});

  @override
  Widget build(BuildContext context) {
    final partner = chat.user2;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Text(partner.name.isEmpty ? '?' : partner.name[0])),
      title: Text(partner.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('Tap to open', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Text('2 min', style: TextStyle(fontSize: 12, color: Colors.grey)),
    );
  }
}
