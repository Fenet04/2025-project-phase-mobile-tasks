import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'data/datasources/chat_local_data_source.dart';
import 'data/datasources/chat_remote_data_source.dart';
import 'data/datasources/chat_socket_service.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'domain/repositories/chat_repository.dart';
import 'domain/usecases/get_chat_by_id.dart';
import 'domain/usecases/get_chat_messages.dart';
import 'domain/usecases/get_my_chats.dart';
import 'domain/usecases/initiate_chat.dart';
import 'domain/usecases/send_message.dart';

class ChatModule {
  static http.Client? _client;
  static SharedPreferences? _prefs;

  static ChatRemoteDataSource? _remote;
  static ChatLocalDataSource? _local;
  static ChatSocketService? _socket;
  static ChatRepository? _repo;

  static GetMyChats? _getMyChats;
  static GetChatById? _getChatById;
  static GetChatMessages? _getChatMessages;
  static InitiateChat? _initiateChat;
  static SendMessage? _sendMessage;

  static String Function()? _tokenProvider;

  static Future<void> init({required String Function() tokenProvider}) async {
    if (_tokenProvider != null) return;
    _tokenProvider = tokenProvider;

    _client = http.Client();
    _prefs = await SharedPreferences.getInstance();

    _remote = ChatRemoteDataSourceImpl(_client!);
    _local  = ChatLocalDataSourceImpl(_prefs!);
    _socket = ChatSocketServiceImpl();

    _repo = ChatRepositoryImpl(
      remote: _remote!,
      local: _local!,
      socket: _socket!,
      tokenProvider: () => _tokenProvider?.call() ?? '',
    );

    _getMyChats      = GetMyChats(_repo!);
    _getChatById     = GetChatById(_repo!);
    _getChatMessages = GetChatMessages(_repo!);
    _sendMessage     = SendMessage(_repo!);
    _initiateChat    = InitiateChat(_repo!);
  }

  static String? _myId;

  static Future<String> getMyId() async {
    if(_myId != null) return _myId!;
    final t = _tokenProvider?.call() ?? '';
    if (t.isEmpty) return '';
    final uri = Uri.parse('https://g5-flutter-learning-path-be-tvum.onrender.com/api/v2/users/me');
    try {
      final res = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $t',
      }).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return '';
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final data = (decoded['data'] ?? {}) as Map<String, dynamic>;
      _myId = (data['_id'] ?? data['id'] ?? '').toString();
      return _myId!;
    } catch (_) {
      return '';
    }
  }

  static GetMyChats get getMyChats => _getMyChats!;
  static GetChatById get getChatById => _getChatById!;
  static GetChatMessages get getChatMessages => _getChatMessages!;
  static SendMessage get sendMessage => _sendMessage!;
  static ChatSocketService get socket => _socket!;
  static String Function() get token => _tokenProvider!;
  static InitiateChat get initiateChat => _initiateChat!;
}
