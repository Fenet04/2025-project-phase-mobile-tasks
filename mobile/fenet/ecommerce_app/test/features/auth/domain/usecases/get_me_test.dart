import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/get_me.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetMeUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = GetMeUsecase(mockAuthRepository);
  });

  const tToken = 'sample_token';
  const tEmail = 'user@gmail.com';
  const tPassword = 'userpassword';
  const tUser = User(id: '1', name: 'Mr. User', email: tEmail, password: tPassword);

  test('should return User when getMe is successful', () async {
    when(() => mockAuthRepository.getMe(token: tToken)).thenAnswer((_) async => const Right(tUser));

    final result = await usecase(token: tToken);

    expect(result, const Right(tUser));
    verify(() => mockAuthRepository.getMe(token: tToken)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return CacheFailure when getMe fails', () async {
    when(() => mockAuthRepository.getMe(token: tToken)).thenAnswer((_) async => Left(CacheFailure()));

    final result = await usecase(token: tToken);

    expect(result, equals(Left(CacheFailure())));
    verify(() => mockAuthRepository.getMe(token: tToken)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}