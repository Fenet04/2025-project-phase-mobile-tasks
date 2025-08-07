import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/error/exception.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/core/platform/network_info.dart';
import 'package:ecommerce_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ecommerce_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ecommerce_app/features/auth/data/models/user_model.dart';
import 'package:ecommerce_app/features/auth/data/repositories/auth_repository_impl.dart';

class MockRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AuthRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('login', () {
    const email = 'user@gmail.com';
    const password = 'userpassword';
    const token = 'sample_token';

    test('should return token and cache it when online and successful', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.login(email: email, password: password)).thenAnswer((_) async => token);
      when(() => mockLocalDataSource.cacheToken(token)).thenAnswer((_) async => {});

      final result = await repository.login(email: email, password: password);

      expect(result, Right(token));
      verify(() => mockLocalDataSource.cacheToken(token)).called(1);
    });

    test('should return ServerFailure on ServerException', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.login(email: email, password: password)).thenThrow(ServerException());

      final result = await repository.login(email: email, password: password);

      expect(result, Left(ServerFailure()));
    });

    test('should return NetworkFailure when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.login(email: email, password: password);

      expect(result, Left(NetworkFailure()));
    });
  });

  group('register', () {
    const name = 'Mr. User';
    const email = 'user@gmail.com';
    const password = 'userpassword';
    const userModel = UserModel(id: '1', name: name, email: email, password: password);

    test('should return User when register successful and online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.register(name: name, email: email, password: password))
        .thenAnswer((_) async => userModel);

      final result = await repository.register(name: name, email: email, password: password);

      expect(result, Right(userModel));
    });

    test('should return ServerFailure on ServerException', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.register(name: name, email: email, password: password))
        .thenThrow(ServerException());

      final result = await repository.register(name: name, email: email, password: password);

      expect(result, Left(ServerFailure()));
    });

    test('should return NetworkFailure when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.register(name: name, email: email, password: password);

      expect(result, Left(NetworkFailure()));
    });
  });

  group('getMe', () {
    const token = 'token_abc';
    const userModel = UserModel(id: '1', name: 'Mr. User', email: 'user@gmail.com', password: 'userpassword');

    test('should return User when cached token exists and remote call succeeds', () async {
      when(() => mockLocalDataSource.getCachedToken()).thenAnswer((_) async => token);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getMe(token: token)).thenAnswer((_) async => userModel);

      final result = await repository.getMe(token: token);

      expect(result, Right(userModel));
    });

    test('should return CacheFailure when no cached token', () async {
      when(() => mockLocalDataSource.getCachedToken()).thenAnswer((_) async => null);

      final result = await repository.getMe(token: token);

      expect(result, Left(CacheFailure(message: 'No token found')));
    });

    test('should return ServerFailure on ServerException', () async {
      when(() => mockLocalDataSource.getCachedToken()).thenAnswer((_) async => token);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getMe(token: token)).thenThrow(ServerException());

      final result = await repository.getMe(token: token);

      expect(result, Left(ServerFailure()));
    });

    test('should return NetworkFailure when offline', () async {
      when(() => mockLocalDataSource.getCachedToken()).thenAnswer((_) async => token);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getMe(token: token);

      expect(result, Left(NetworkFailure()));
    });
  });
}