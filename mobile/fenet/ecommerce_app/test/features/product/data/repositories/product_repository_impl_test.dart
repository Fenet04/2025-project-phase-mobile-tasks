import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/error/exception.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/core/platform/network_info.dart';
import 'package:ecommerce_app/features/product/data/datasources/product_local_data_source.dart';
import 'package:ecommerce_app/features/product/data/datasources/product_remote_data_source.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:ecommerce_app/features/product/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock implements ProductRemoteDataSource {}

class MockLocalDataSource extends Mock implements ProductLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late ProductRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  final tProductModel = ProductModel(
    id: '1',
    name: 'Polene bag',
    description: 'Leather sculptured tote bag',
    imageUrl: 'image.jpg',
    price: 540.00,
  );

  final Product tProduct = tProductModel;
  final tProductList = [tProductModel];

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('getAllProducts', () {
    test('should check if the device is online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getAllProducts()).thenAnswer((_) async => tProductList);
      when(() => mockLocalDataSource.cacheProducts(tProductList)).thenAnswer((_) async {});

      repository.getAllProducts();
      verify(() => mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test('should return remote data when successful', () async {
        when(() => mockRemoteDataSource.getAllProducts()).thenAnswer((_) async => tProductList);
        when(() => mockLocalDataSource.cacheProducts(tProductList)).thenAnswer((_) async {});

        final result = await repository.getAllProducts();
        expect(result, equals(Right(tProductList)));
      });

      test('should return ServerFailure on exception', () async {
        when(() => mockRemoteDataSource.getAllProducts()).thenThrow(ServerException());
        final result = await repository.getAllProducts();
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test('should return cached data when present', () async {
        when(() => mockLocalDataSource.getLastProducts()).thenAnswer((_) async => tProductList);
        final result = await repository.getAllProducts();
        expect(result, equals(Right(tProductList)));
      });

      test('should return CacheFailure when no cache', () async {
        when(() => mockLocalDataSource.getLastProducts()).thenThrow(CacheException());
        final result = await repository.getAllProducts();
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });

  group('getProduct', () {
    runTestsOnline(() {
      test('should return remote data when successful', () async {
        when(() => mockRemoteDataSource.getProduct('1')).thenAnswer((_) async => tProductModel);
        final result = await repository.getProduct('1');
        expect(result, equals(Right(tProduct)));
      });

      test('should return ServerFailure on exception', () async {
        when(() => mockRemoteDataSource.getProduct('1')).thenThrow(ServerException());
        final result = await repository.getProduct('1');
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test('should return cached product if present', () async {
        when(() => mockLocalDataSource.getLastProducts()).thenAnswer((_) async => tProductList);
        final result = await repository.getProduct('1');
        expect(result, equals(Right(tProduct)));
      });

      test('should return CacheFailure if not cached', () async {
        when(() => mockLocalDataSource.getLastProducts()).thenThrow(CacheException());
        final result = await repository.getProduct('1');
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });

  group('createProduct', () {
    runTestsOnline(() {
      test('should call remote data source when online', () async {
        when(() => mockRemoteDataSource.createProduct(tProductModel)).thenAnswer((_) async => {});
        final result = await repository.createProduct(tProductModel);
        expect(result, equals(Right(null)));
        verify(() => mockRemoteDataSource.createProduct(tProductModel));
      });
    });

    runTestsOffline(() {
      test('should return ServerFailure when offline', () async {
        final result = await repository.createProduct(tProductModel);
        expect(result,equals(Left(ServerFailure())));
      });
    });
  });

  group('updateProduct', () {
    runTestsOnline(() {
      test('should call remote data source when online', () async {
        when(() => mockRemoteDataSource.updateProduct(tProductModel)).thenAnswer((_) async => {});
        final result = await repository.updateProduct(tProductModel);
        expect(result, equals(Right(null)));
      });
    });

    runTestsOffline(() {
      test('should return ServerFailure when offline', () async {
        final result = await repository.updateProduct(tProductModel);
        expect(result, equals(Left(ServerFailure())));
      });
    });
  });

  group('deleteProduct', () {
    runTestsOnline(() {
      test('should call remote data source when online', () async {
        when(() => mockRemoteDataSource.deleteProduct('1')).thenAnswer((_) async => {});
        final result = await repository.deleteProduct('1');
        expect(result, equals(Right(null)));
      });
    });

    runTestsOffline(() {
      test('should return ServerFailure when offline', () async {
        final result = await repository.deleteProduct('1');
        expect(result, equals(Left(ServerFailure())));
      });
    });
  });
}













