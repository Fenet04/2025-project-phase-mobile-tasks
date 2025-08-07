import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/exception.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';
import '../../../../core/platform/network_info.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> login({required String email, required String password}) async {
    if (await networkInfo.isConnected) {
      try {
        final token = await remoteDataSource.login(email: email, password: password);
        await localDataSource.cacheToken(token);
        return Right(token);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> register({required String name, required String email, required String password}) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.register(name: name, email: email, password: password);
        return Right(user);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getMe({required String token}) async {
    final token = await localDataSource.getCachedToken();
    
    if (token == null) {
      return Left(CacheFailure(message: 'No token found'));
    }

    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.getMe(token: token);
        return Right(user);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
    
  }
}