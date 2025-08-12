import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repo;

  SendMessage(this.repo);

  Future<Either<Failure, Message>> call({
    required String chatId,
    required String content,
    String type = 'text',
  }) {
    return repo.sendMessage(chatId: chatId, content: content, type: type);
  }
}