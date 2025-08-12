import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

class GetMyChats {
  final ChatRepository repo;
  GetMyChats(this.repo);

  Future<Either<Failure, List<Chat>>> call() {
    return repo.getMyChats();
  } 
}