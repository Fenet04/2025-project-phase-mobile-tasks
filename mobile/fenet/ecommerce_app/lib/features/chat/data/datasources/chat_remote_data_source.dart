import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/error/exception.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatModel>> getMyChats({required String token});
  Future<ChatModel> getChatById({required String token, required String chatId});
  Future<List<MessageModel>> getChatMessages({required String token, required String chatId});
  Future<ChatModel> initiateChat({required String token, required String userId});
  Future<void> deleteChat({required String token, required String chatId});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  static const baseUrl = 'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v3';

  ChatRemoteDataSourceImpl(this.client);

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  List<Map<String, dynamic>> _decodeList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) return data.cast<Map<String, dynamic>>();
    }
    throw ServerException();
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data == null) return decoded;
      if (data is Map<String, dynamic>) return data;
    }
    throw ServerException();
  }

  @override
  Future<List<ChatModel>> getMyChats({required String token}) async {
    final res = await client.get(Uri.parse('$baseUrl/chats'), headers: _headers(token));
    if (res.statusCode == 200) {
      final list = _decodeList(res.body);
      return list.map((e) => ChatModel.fromJson(e)).toList();
    }
    throw ServerException();
  }

  @override
  Future<ChatModel> getChatById({required String token, required String chatId}) async {
    final res = await client.get(Uri.parse('$baseUrl/chats/$chatId'), headers: _headers(token));
    if (res.statusCode == 200) {
      final obj = _decodeObject(res.body);
      return ChatModel.fromJson(obj);
    }
    throw ServerException();
  }

  @override
  Future<List<MessageModel>> getChatMessages({required String token, required String chatId}) async {
    final res = await client.get(Uri.parse('$baseUrl/chats/$chatId/messages'), headers: _headers(token));
    if (res.statusCode == 200) {
      final list = _decodeList(res.body);
      return list.map((e) => MessageModel.fromJson(e)).toList();
    }
    throw ServerException();
  }

  @override
  Future<ChatModel> initiateChat({required String token, required String userId}) async {
    final res = await client.post(
      Uri.parse('$baseUrl/chats'),
      headers: _headers(token),
      body: jsonEncode({'userId': userId}),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      final obj = _decodeObject(res.body);
      return ChatModel.fromJson(obj);
    }
    throw ServerException();
  }

  @override
  Future<void> deleteChat({required String token, required String chatId}) async {
    final res = await client.delete(Uri.parse('$baseUrl/chats/$chatId'), headers: _headers(token));
    if (res.statusCode == 200 || res.statusCode == 204) return;
    throw ServerException();
  }
}
