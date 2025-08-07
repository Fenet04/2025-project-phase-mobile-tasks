import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUsecase(mockAuthRepository);
  });

  const tEmail = 'user@gmail.com';
  const tPassword = 'userpassword';
  const tAccessToken = 'token_string';

  test('should return access token on successful login', () async {
    when(() => mockAuthRepository.login(email: tEmail, password: tPassword)).thenAnswer((_) async => const Right(tAccessToken));

  final result = await usecase(email: tEmail, password: tPassword);

  expect(result, const Right(tAccessToken));
  verify(() => mockAuthRepository.login(email: tEmail, password: tPassword)).called(1);
  verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return ServerFailure when login fails', () async {
    when(() => mockAuthRepository.login(email: tEmail, password: tPassword)).thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(email: tEmail, password: tPassword);

    expect(result, equals(Left(ServerFailure())));
    verify(() => mockAuthRepository.login(email: tEmail, password: tPassword)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}