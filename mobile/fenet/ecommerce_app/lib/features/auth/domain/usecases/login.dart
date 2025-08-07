import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<Either<Failure, String>> call({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}