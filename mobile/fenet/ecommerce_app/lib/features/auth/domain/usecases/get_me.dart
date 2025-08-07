import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetMeUsecase {
  final AuthRepository repository;

  GetMeUsecase(this.repository);

  Future<Either<Failure, User>> call({required String token}) async {
    return await repository.getMe(token: token);
  }
}