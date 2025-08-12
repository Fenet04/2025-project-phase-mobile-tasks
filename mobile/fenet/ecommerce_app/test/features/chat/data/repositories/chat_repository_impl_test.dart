import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/error/exception.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/chat/data/datasources/chat_local_data_source.dart';
import 'package:ecommerce_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:ecommerce_app/features/chat/data/datasources/chat_socket_service.dart';
import 'package:ecommerce_app/features/chat/data/models/chat_model.dart';
import 'package:ecommerce_app/features/chat/data/models/message_model.dart';
import 'package:ecommerce_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemote extends Mock implements ChatRemoteDataSource {}
class MockLocal extends Mock implements ChatLocalDataSource {}
class MockSocket extends Mock implements ChatSocketService {}

void main() {
  late MockRemote remote;
  late MockLocal local;
  late MockSocket socket;
  late ChatRepositoryImpl repo;

  String tokenProvider() => 't';

  final u1 = User(id: 'u1', name: 'A', email: 'a@a.com', password: '');
  final u2 = User(id: 'u2', name: 'B', email: 'b@b.com', password: '');
  final chatModel = ChatModel(id: 'c1', user1: u1, user2: u2);
  final msgModel = MessageModel(
    id: 'm1',
    chatId: 'c1',
    sender: u1,
    content: 'Hello',
    type: 'text',
  );

  setUp(() {
    remote = MockRemote();
    local = MockLocal();
    socket = MockSocket();
    repo = ChatRepositoryImpl(
      remote: remote,
      local: local,
      socket: socket,
      tokenProvider: tokenProvider,
    );
  });

  void expectRight<E, T>(Either<E, T> either, T expected) {
    expect(either.isRight(), true);
    either.fold((_) => fail('Expected Right but got Left'), (actual) {
      expect(actual, expected);
    });
  }

  void expectLeft<E, T>(Either<E, T> either, E expected) {
    expect(either.isLeft(), true);
    either.fold((actual) => expect(actual, expected), (_) => fail('Expected Left but got Right'));
  }

  group('getMyChats', () {
    test('remote success -> caches -> returns list', () async {
      when(() => remote.getMyChats(token: any(named: 'token')))
          .thenAnswer((_) async => [chatModel]);
      when(() => local.cacheMyChats([chatModel])).thenAnswer((_) async {});

      final res = await repo.getMyChats();

      expectRight(res, [chatModel]);
      verify(() => remote.getMyChats(token: 't')).called(1);
      verify(() => local.cacheMyChats([chatModel])).called(1);
    });

    test('remote throws -> fallback to cache', () async {
      when(() => remote.getMyChats(token: any(named: 'token')))
          .thenThrow(ServerException());
      when(() => local.getCachedMyChats()).thenAnswer((_) async => [chatModel]);

      final res = await repo.getMyChats();

      expectRight(res, [chatModel]);
      verify(() => local.getCachedMyChats()).called(1);
    });

    test('remote throws & cache throws -> failure', () async {
      when(() => remote.getMyChats(token: any(named: 'token')))
          .thenThrow(ServerException());
      when(() => local.getCachedMyChats()).thenThrow(CacheException());

      final res = await repo.getMyChats();

      expectLeft(res, ServerFailure());
    });
  });

  group('getChatById', () {
    test('remote success -> returns chat', () async {
      when(() => remote.getChatById(token: any(named: 'token'), chatId: 'c1'))
          .thenAnswer((_) async => chatModel);

      final res = await repo.getChatById('c1');

      expectRight(res, chatModel);
    });

    test('remote throws -> fallback search in cached chats', () async {
      when(() => remote.getChatById(token: any(named: 'token'), chatId: 'c1'))
          .thenThrow(ServerException());
      when(() => local.getCachedMyChats()).thenAnswer((_) async => [chatModel]);

      final res = await repo.getChatById('c1');

      expectRight(res, chatModel);
    });

    test('remote throws & cache miss -> failure', () async {
      when(() => remote.getChatById(token: any(named: 'token'), chatId: 'c1'))
          .thenThrow(ServerException());
      when(() => local.getCachedMyChats()).thenAnswer((_) async => []);

      final res = await repo.getChatById('c1');

      expectLeft(res, ServerFailure());
    });
  });

  group('getChatMessages', () {
    test('remote success -> caches -> returns list', () async {
      when(() => remote.getChatMessages(token: any(named: 'token'), chatId: 'c1'))
          .thenAnswer((_) async => [msgModel]);
      when(() => local.cacheChatMessages('c1', [msgModel])).thenAnswer((_) async {});

      final res = await repo.getChatMessages('c1');

      expectRight(res, [msgModel]);
      verify(() => local.cacheChatMessages('c1', [msgModel])).called(1);
    });

    test('remote throws -> fallback to cached messages', () async {
      when(() => remote.getChatMessages(token: any(named: 'token'), chatId: 'c1'))
          .thenThrow(ServerException());
      when(() => local.getCachedChatMessages('c1'))
          .thenAnswer((_) async => [msgModel]);

      final res = await repo.getChatMessages('c1');

      expectRight(res, [msgModel]);
    });

    test('remote throws & cache throws -> failure', () async {
      when(() => remote.getChatMessages(token: any(named: 'token'), chatId: 'c1'))
          .thenThrow(ServerException());
      when(() => local.getCachedChatMessages('c1')).thenThrow(CacheException());

      final res = await repo.getChatMessages('c1');

      expectLeft(res, ServerFailure());
    });
  });

  group('initiateChat', () {
    test('remote success -> upsert into cached list', () async {
      when(() => remote.initiateChat(token: any(named: 'token'), userId: 'target'))
          .thenAnswer((_) async => chatModel);
      when(() => local.getCachedMyChats()).thenAnswer((_) async => <ChatModel>[]);
      when(() => local.cacheMyChats(any())).thenAnswer((_) async {});

      final res = await repo.initiateChat('target');

      expectRight(res, chatModel);
    });

    test('remote throws -> failure', () async {
      when(() => remote.initiateChat(token: any(named: 'token'), userId: 'x'))
          .thenThrow(ServerException());

      final res = await repo.initiateChat('x');

      expectLeft(res, ServerFailure());
    });
  });

  group('deleteChat', () {
    test('remote success -> clears caches', () async {
      when(() => remote.deleteChat(token: any(named: 'token'), chatId: 'c1'))
          .thenAnswer((_) async {});
      when(() => local.clearChatCache('c1')).thenAnswer((_) async {});
      when(() => local.getCachedMyChats()).thenAnswer((_) async => [chatModel]);
      when(() => local.cacheMyChats(any())).thenAnswer((_) async {});

      final res = await repo.deleteChat('c1');

      expectRight(res, null);
    });

    test('remote throws -> failure', () async {
      when(() => remote.deleteChat(token: any(named: 'token'), chatId: 'c1'))
          .thenThrow(ServerException());

      final res = await repo.deleteChat('c1');

      expectLeft(res, ServerFailure());
    });
  });

  group('sendMessage', () {
    test('connects socket if needed, sends, caches delivered', () async {
      when(() => socket.isConnected).thenReturn(false);
      when(() => socket.connect(token: any(named: 'token'))).thenAnswer((_) async {});
      when(() => socket.sendMessage(chatId: 'c1', content: 'Hello', type: 'text'))
          .thenAnswer((_) async => msgModel);
      when(() => local.upsertCachedMessage('c1', msgModel)).thenAnswer((_) async {});

      final res = await repo.sendMessage(chatId: 'c1', content: 'Hello', type: 'text');

      expectRight(res, msgModel);
    });

    test('when socket already connected, does not reconnect', () async {
      when(() => socket.isConnected).thenReturn(true);
      when(() => socket.sendMessage(chatId: 'c1', content: 'Hello', type: 'text'))
          .thenAnswer((_) async => msgModel);
      when(() => local.upsertCachedMessage('c1', msgModel)).thenAnswer((_) async {});

      final res = await repo.sendMessage(chatId: 'c1', content: 'Hello', type: 'text');

      expectRight(res, msgModel);
      verifyNever(() => socket.connect(token: any(named: 'token')));
    });

    test('propagates errors as ServerFailure', () async {
      when(() => socket.isConnected).thenReturn(true);
      when(() => socket.sendMessage(chatId: 'c1', content: 'Hello', type: 'text'))
          .thenThrow(StateError('timeout'));

      final res = await repo.sendMessage(chatId: 'c1', content: 'Hello', type: 'text');

      expect(res.isLeft(), true);
    });
  });
}
