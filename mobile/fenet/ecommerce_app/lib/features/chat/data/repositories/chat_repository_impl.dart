import 'package:dartz/dartz.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../datasources/chat_socket_service.dart';
import '../models/chat_model.dart';

class ChatRepositoryImpl implements ChatRepository{
  final ChatRemoteDataSource remote;
  final ChatLocalDataSource local;
  final ChatSocketService socket;
  final String Function() tokenProvider;

  ChatRepositoryImpl({
    required this.remote,
    required this.local,
    required this.socket,
    required this.tokenProvider,
  });

  @override
  Future<Either<Failure, List<Chat>>> getMyChats() async {
    try {
      final token = tokenProvider();
      final models = await remote.getMyChats(token: token);
      await local.cacheMyChats(models);
      return Right(models);
    } on ServerException {
      try {
        final cached = await local.getCachedMyChats();
        return Right(cached);
      } catch (_) {
        return Left(ServerFailure());
      }
    } catch (e) {
      return Left(ServerFailure(message: e. toString()));
    }
  }

  @override
  Future<Either<Failure, Chat>> getChatById(String chatId) async {
    try {
      final token = tokenProvider();
      final model = await remote.getChatById(token: token, chatId: chatId);
      return Right(model);
    } on ServerException{
      try {
        final cached = await local.getCachedMyChats();
        final hit = cached.firstWhere((c) => c.id == chatId);
        return Right(hit);
      } catch (_) {
        return Left(ServerFailure());
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getChatMessages(String chatId) async {
    try {
      final token = tokenProvider();
      final models = await remote.getChatMessages(token: token, chatId: chatId);
      await local.cacheChatMessages(chatId, models);
      return Right(models);
    } on ServerException {
      try {
        final cached = await local.getCachedChatMessages(chatId);
        return Right(cached);
      } catch (_) {
        return Left(ServerFailure());
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Chat>> initiateChat(String userId) async {
    try {
      final token = tokenProvider();
      final model = await remote.initiateChat(token: token, userId: userId);

      final existing = await local.getCachedMyChats().catchError((_) => <ChatModel>[]);
      final list = List<ChatModel>.from(existing);
      final idx = list.indexWhere((c) => c.id == model.id);
      if (idx >= 0) {
        list[idx] = model;
      } else {
        list.insert(0, model);
      }
      await local.cacheMyChats(list);

      return Right(model);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChat(String chatId) async {
    try {
      final token = tokenProvider();
      await remote.deleteChat(token: token, chatId: chatId);

      await local.clearChatCache(chatId);
      final existing = await local.getCachedMyChats().catchError((_) => <ChatModel>[]);
      final pruned = existing.where((c) => c.id != chatId).toList();
      await local.cacheMyChats(pruned);

      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String chatId,
    required String content,
    required String type,
  }) async {
    try {
      final token = tokenProvider();
      if (!socket.isConnected) {
        await socket.connect(token: token);
      }

      final delivered = await socket.sendMessage(
        chatId: chatId,
        content: content,
        type: type,
      );

      await local.upsertCachedMessage(chatId, delivered);

      return Right(delivered);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  void bindSocketStreams() {
    socket.onMessageDelivered().listen((m) {
      local.upsertCachedMessage(m.chatId, m);
    });
    socket.onMessageReceived().listen((m) {
      local.upsertCachedMessage(m.chatId, m);
    });
  }
}