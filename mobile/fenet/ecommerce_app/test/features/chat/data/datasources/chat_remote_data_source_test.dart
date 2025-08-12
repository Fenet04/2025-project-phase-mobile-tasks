import 'dart:convert';

import 'package:ecommerce_app/core/error/exception.dart';
import 'package:ecommerce_app/features/auth/data/models/user_model.dart';
import 'package:ecommerce_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:ecommerce_app/features/chat/data/models/chat_model.dart';
import 'package:ecommerce_app/features/chat/data/models/message_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

/// Needed for mocktail when matching `Uri` arguments
class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockHttp;
  late ChatRemoteDataSourceImpl dataSource;


  final u1 = UserModel(id: 'u1', name: 'A', email: 'a@a.com', password: '');
  final u2 = UserModel(id: 'u2', name: 'B', email: 'b@b.com', password: '');

  final chatModel = ChatModel(id: 'c1', user1: u1, user2: u2);
  final msgModel = MessageModel(
    id: 'm1',
    chatId: 'c1',
    sender: u1,
    content: 'Hello',
    type: 'text',
  );

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockHttp = MockHttpClient();
    dataSource = ChatRemoteDataSourceImpl(mockHttp);
  });

  group('getMyChats', () {
    test('returns list on 200', () async {
      when(() => mockHttp.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => http.Response(jsonEncode([chatModel.toJson()]), 200));

      final result = await dataSource.getMyChats(token: 't');

      expect(result, [chatModel]);
      verify(() => mockHttp.get(any(), headers: any(named: 'headers')))
          .called(1);
    });

    test('throws ServerException on non-200', () async {
      when(() => mockHttp.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('error', 500));

      expect(() => dataSource.getMyChats(token: 't'),
          throwsA(isA<ServerException>()));
    });
  });

  group('getChatById', () {
    test('returns chat on 200', () async {
      when(() => mockHttp.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => http.Response(jsonEncode(chatModel.toJson()), 200));

      final result = await dataSource.getChatById(token: 't', chatId: 'c1');

      expect(result, chatModel);
    });

    test('throws ServerException on non-200', () async {
      when(() => mockHttp.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('err', 404));

      expect(() => dataSource.getChatById(token: 't', chatId: 'c1'),
          throwsA(isA<ServerException>()));
    });
  });

  group('getChatMessages', () {
    test('returns list on 200', () async {
      when(() => mockHttp.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => http.Response(jsonEncode([msgModel.toJson()]), 200));

      final result =
          await dataSource.getChatMessages(token: 't', chatId: 'c1');

      expect(result, [msgModel]);
    });

    test('throws ServerException on non-200', () async {
      when(() => mockHttp.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('err', 500));

      expect(() => dataSource.getChatMessages(token: 't', chatId: 'c1'),
          throwsA(isA<ServerException>()));
    });
  });

  group('initiateChat', () {
    test('returns chat on 200', () async {
      when(() => mockHttp.post(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer(
              (_) async => http.Response(jsonEncode(chatModel.toJson()), 200));

      final result =
          await dataSource.initiateChat(token: 't', userId: 'target');

      expect(result, chatModel);
    });

    test('throws ServerException on non-200', () async {
      when(() => mockHttp.post(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('err', 400));

      expect(() => dataSource.initiateChat(token: 't', userId: 'target'),
          throwsA(isA<ServerException>()));
    });
  });

  group('deleteChat', () {
    test('completes on 200', () async {
      when(() => mockHttp.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('', 200));

      await dataSource.deleteChat(token: 't', chatId: 'c1');

      verify(() => mockHttp.delete(any(), headers: any(named: 'headers')))
          .called(1);
    });

    test('throws ServerException on non-200', () async {
      when(() => mockHttp.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('err', 500));

      expect(() => dataSource.deleteChat(token: 't', chatId: 'c1'),
          throwsA(isA<ServerException>()));
    });
  });
}
