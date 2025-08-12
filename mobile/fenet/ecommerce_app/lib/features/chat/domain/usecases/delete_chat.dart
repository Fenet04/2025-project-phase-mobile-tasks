import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/chat_repository.dart';

class DeleteChat {
  final ChatRepository repo;
  
  DeleteChat(this.repo);

  Future<Either<Failure, void>> call(String chatId) {
    return repo.deleteChat(chatId);
  }
}