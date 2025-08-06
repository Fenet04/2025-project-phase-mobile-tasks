import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/product/domain/entities/product.dart';
import 'package:ecommerce_app/features/product/domain/repositories/product_repository.dart';
import 'package:ecommerce_app/features/product/domain/usecases/create_product.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late CreateProductUsecase usecase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    usecase = CreateProductUsecase(mockRepository);
  });

  const tProduct = Product(
    id: '1',
    name: 'Polene bag',
    description: 'Leather sculptured tote bag',
    imageUrl: 'image.jpg',
    price: 540.00,
  );

  test('should call repository.creatProduct with the correct product', () async {
    when(() => mockRepository.createProduct(tProduct)).thenAnswer((_) async => const Right(null));
    final result = await usecase(tProduct);
    expect(result, const Right(null));
    verify(() => mockRepository.createProduct(tProduct)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    final failure = CacheFailure();
    when(() => mockRepository.createProduct(tProduct)).thenAnswer((_) async => Left(failure));
    final result = await usecase(tProduct);
    expect(result, Left(failure));
    verify(() => mockRepository.createProduct(tProduct)).called(1);
  });
}