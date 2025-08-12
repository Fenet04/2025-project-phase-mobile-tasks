import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

class InitiateChat {
  final ChatRepository repo;

  InitiateChat(this.repo);

  Future<Either<Failure, Chat>> call(String userId) {
    return repo.initiateChat(userId);
  }
}