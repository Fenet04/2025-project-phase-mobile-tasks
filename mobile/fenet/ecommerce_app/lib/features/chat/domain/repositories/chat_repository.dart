import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/chat.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Chat>>> getMyChats();
  Future<Either<Failure, Chat>> getChatById(String chatId);
  Future<Either<Failure, List<Message>>> getChatMessages(String chatId);
  Future<Either<Failure, Chat>> initiateChat(String userId);
  Future<Either<Failure, void>> deleteChat(String chatId);
  Future<Either<Failure, Message>> sendMessage({
    required String chatId,
    required String content,
    required String type,
  });
}