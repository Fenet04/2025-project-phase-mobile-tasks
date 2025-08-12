import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exception.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class ChatLocalDataSource {
  Future<void> cacheMyChats(List<ChatModel> chats);
  Future<List<ChatModel>> getCachedMyChats();
  Future<void> cacheChatMessages(String chatId, List<MessageModel> messages);
  Future<List<MessageModel>> getCachedChatMessages(String chatId);
  Future<void> upsertCachedMessage(String chatId, MessageModel message);
  Future<void> clearChatCache(String chatId);
}

const _kChatsKey = 'chat_cached_chats_v1';
String _messagesKey(String chatId) => 'chat_cached_messages_v1_$chatId';

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final SharedPreferences prefs;
  ChatLocalDataSourceImpl(this.prefs);

  @override
  Future<void> cacheMyChats(List<ChatModel> chats) async {
    final list = chats.map((c) => c.toJson()).toList();
    final ok = await prefs.setString(_kChatsKey, jsonEncode(list));
    if (!ok) throw CacheException();
  }

  @override
  Future<List<ChatModel>> getCachedMyChats() async {
    final raw = prefs.getString(_kChatsKey);
    if (raw == null) throw CacheException();
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => ChatModel.fromJson(e)).toList();
  }

  @override
  Future<void> cacheChatMessages(String chatId, List<MessageModel> messages) async {
    final list = messages.map((m) => m.toJson()).toList();
    final ok = await prefs.setString(_messagesKey(chatId), jsonEncode(list));
    if (!ok) throw CacheException();
  }

  @override
  Future<List<MessageModel>> getCachedChatMessages(String chatId) async {
    final raw = prefs.getString(_messagesKey(chatId));
    if (raw == null) throw CacheException();
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => MessageModel.fromJson(e)).toList();
  }

  @override
  Future<void> upsertCachedMessage(String chatId, MessageModel message) async {
    List<MessageModel> current = [];
    try {
      current = await getCachedChatMessages(chatId);
    } catch (_) {}
    final index = current.indexWhere((m) => m.id == message.id);
    if (index >= 0) {
      current[index] = message;
    } else {
      current.add(message);
    }
    await cacheChatMessages(chatId, current);
  }

  @override
  Future<void> clearChatCache(String chatId) async {
    await prefs.remove(_messagesKey(chatId));
  }
}