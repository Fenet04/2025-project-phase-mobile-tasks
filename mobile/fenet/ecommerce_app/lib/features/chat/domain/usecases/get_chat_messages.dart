import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetChatMessages {
  final ChatRepository repo;
  
  GetChatMessages(this.repo);

  Future<Either<Failure, List<Message>>> call(String chatId) {
    return repo.getChatMessages(chatId);
  }
}