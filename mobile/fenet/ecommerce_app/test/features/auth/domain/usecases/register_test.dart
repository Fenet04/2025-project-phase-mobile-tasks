import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/register.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = RegisterUsecase(mockAuthRepository);
  });

  const tName = 'Mr. User';
  const tEmail = 'user@gmail.com';
  const tPassword = 'userpassword';
  const tUser = User(id: '1', name: tName, email: tEmail, password: tPassword);

  test('should return User on successful registration', () async {
    when(() => mockAuthRepository.register(name: tName, email: tEmail, password: tPassword))
      .thenAnswer((_) async => const Right(tUser));
    
    final result = await usecase(name: tName, email: tEmail, password: tPassword);

    expect(result, const Right(tUser));
    verify(() => mockAuthRepository.register(name: tName, email: tEmail, password: tPassword)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return ServerFailure when registeration fails', () async {
    when(() => mockAuthRepository.register(name: tName, email: tEmail, password: tPassword))
      .thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase(name: tName, email: tEmail, password: tPassword);

    expect(result, equals(Left(ServerFailure())));
    verify(() => mockAuthRepository.register(name: tName, email: tEmail, password: tPassword)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}