import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../auth/domain/entities/user.dart' as auth;
import '../../chat_module.dart';
import '../../domain/entities/chat.dart';
import '../bloc/chat_list/chat_list_bloc.dart';
import 'chat_page.dart';

class ChatListScreen extends StatefulWidget {
  final String Function() tokenProvider;
  const ChatListScreen({super.key, required this.tokenProvider});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _ready = false;
  String _myId = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ChatModule.init(tokenProvider: widget.tokenProvider);
      _myId = await ChatModule.getMyId();
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider(
      create: (_) => ChatListBloc(ChatModule.getMyChats)..add(const ChatListStarted()),
      child: _ChatListShell(myId: _myId),
    );
  }
}

class _ChatListShell extends StatelessWidget {
  final String myId;
  const _ChatListShell({required this.myId});

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_ChatListScreenState>()!;
    final myId = state._myId;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openStartChatSheet(context),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            context.read<ChatListBloc>().add(const ChatListRefreshed()),
        child: CustomScrollView(
          slivers: [
            const _Header(),
            BlocBuilder<ChatListBloc, ChatListState>(
              builder: (context, state) {
                if (state is ChatListLoaded && state.chats.isNotEmpty) {
                  final users = _uniqueOtherUsers(state.chats);
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 86,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        scrollDirection: Axis.horizontal,
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final u = users[i];
                          return Column(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: const Color(0xFFEAF0FF),
                                child: Text(u.name.isEmpty ? '?' : u.name[0]),
                              ),
                              const SizedBox(height: 6),
                              Text(u.name, style: const TextStyle(fontSize: 12)),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
            BlocBuilder<ChatListBloc, ChatListState>(
              builder: (context, state) {
                if (state is ChatListLoading) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is ChatListLoaded) {
                  final chats = state.chats;
                  if (chats.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(),
                    );
                  }
                  return SliverList.separated(
                    itemCount: chats.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final chat = chats[i];
                      final partner = chat.user1.id == myId ? chat.user2: chat.user1 ;
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(partner.name.isEmpty ? '?' : partner.name[0]),
                        ),
                        title: Text(
                          partner.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text('Tap to open',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () {
                          Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                chatId: chat.id,
                                tokenProvider: ChatModule.token,
                                myId: myId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<auth.User> _uniqueOtherUsers(List<Chat> chats) {
    final map = <String, auth.User>{};
    for (final c in chats) {
      map[c.user1.id] = c.user1;
      map[c.user2.id] = c.user2;
    }
    return map.values.toList();
  }

  Future<void> _openStartChatSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _StartChatSheet(),
    );

    if (context.mounted) {
      context.read<ChatListBloc>().add(const ChatListRefreshed());
    }
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      expandedHeight: 96,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6AA9FF), Color(0xFF6C63FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: const [
                Expanded(
                  child: Text('Chats',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ),
                Icon(Icons.search, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.forum_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          const Text('No chats yet', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Tap the + button to start a conversation',
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _StartChatSheet extends StatefulWidget {
  const _StartChatSheet();

  @override
  State<_StartChatSheet> createState() => _StartChatSheetState();
}

class _StartChatSheetState extends State<_StartChatSheet> {
  final _controller = TextEditingController();
  List<auth.User> _allUsers = [];
  List<auth.User> _filtered = [];
  bool _loading = true;
  String _info = '';

  static const String baseV3 =
      'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v3';

  @override
  void initState() {
    super.initState();
    _loadAllUsersOnOpen();
    _controller.addListener(() => _applyFilter(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAllUsersOnOpen() async {
    setState(() {
      _loading = true;
      _info = 'Loading users…';
    });

    final uri = Uri.parse('$baseV3/users');
    final token = ChatModule.token();

    try {
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));


      if (res.statusCode != 200) {
        setState(() {
          _loading = false;
          _allUsers = [];
          _filtered = [];
          _info = 'Server returned ${res.statusCode}.';
        });
        return;
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final list = (decoded['data'] as List?) ?? const [];

      final users = list.map<auth.User>((e) {
        final m = (e as Map).cast<String, dynamic>();
        return auth.User(
          id: (m['_id'] ?? '').toString(),
          name: (m['name'] ?? '').toString(),
          email: (m['email'] ?? '').toString(),
          password: '',
        );
      }).toList();

      const meId = '';
      final cleaned = meId.isEmpty ? users : users.where((u) => u.id != meId).toList();

      setState(() {
        _allUsers = cleaned;
        _filtered = cleaned;
        _loading = false;
        _info = 'Loaded ${cleaned.length} users';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _allUsers = [];
        _filtered = [];
        _info = 'Network error. Please try again.';
      });
      print('Users load error: $e');
    }
  }

  void _applyFilter(String q) {
    final t = q.trim().toLowerCase();
    if (t.isEmpty) {
      setState(() => _filtered = _allUsers);
      return;
    }
    setState(() {
      _filtered = _allUsers.where((u) {
        final name = u.name.toLowerCase();
        final email = u.email.toLowerCase();
        return name.contains(t) || email.contains(t);
      }).toList();
    });
  }

  Future<void> _startChat(auth.User user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final r = await ChatModule.initiateChat(user.id);
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    r.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (chat) async {
        final myId = await ChatModule.getMyId();
        if (!mounted) return;
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: chat.id,
              tokenProvider: ChatModule.token,
              myId: myId,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Start new chat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (_loading)
                const LinearProgressIndicator(minHeight: 2)
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _info,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Search by name or email…',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: _loading
                    ? const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _filtered.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'No users found',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) {
                              final u = _filtered[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(u.name.isEmpty ? '?' : u.name[0]),
                                ),
                                title: Text(u.name),
                                subtitle: Text(u.email),
                                onTap: () => _startChat(u),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
