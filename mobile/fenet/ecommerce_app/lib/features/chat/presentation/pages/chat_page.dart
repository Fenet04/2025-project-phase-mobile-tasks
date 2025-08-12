import 'package:flutter/material.dart';

import '../../../auth/domain/entities/user.dart' as auth;
import '../../chat_module.dart';
import '../../domain/entities/message.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String Function() tokenProvider;
  final String myId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.tokenProvider,
    required this.myId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  bool _loading = true;
  bool _sending = false;
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    final res = await ChatModule.getChatMessages(widget.chatId);
    if (!mounted) return;
    res.fold(
      (f) {
        setState(() {
          _messages = [];
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
      },
      (list) {
        setState(() {
          _messages = list;
          _loading = false;
        });
        _jumpToBottom();
      },
    );
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);

    final res = await ChatModule.sendMessage(
      chatId: widget.chatId,
      content: text,
      type: 'text',
    );

    if (!mounted) return;

    res.fold(
      (f) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
      },
      (msg) {
        setState(() {
          _messages.add(msg);
          _sending = false;
        });
        _controller.clear();
        _jumpToBottom();
      },
    );
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('Say hi 👋'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final m = _messages[i];
                          final isMe = _amISender(m.sender);
                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              constraints: const BoxConstraints(maxWidth: 280),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFF6C63FF)
                                    : const Color(0xFFEFF1F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                m.content,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Message…',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sending
                      ? const SizedBox(
                          width: 36, height: 36,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _handleSend,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _amISender(auth.User sender) {
    return sender.id == widget.myId;
  }
}
