import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

class GetChatById {
  final ChatRepository repo;
  GetChatById(this.repo);

  Future<Either<Failure, Chat>> call(String chatId) {
    return repo.getChatById(chatId);
  }
}