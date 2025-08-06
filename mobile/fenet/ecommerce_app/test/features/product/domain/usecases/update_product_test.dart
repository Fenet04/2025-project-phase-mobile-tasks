import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/product/domain/entities/product.dart';
import 'package:ecommerce_app/features/product/domain/repositories/product_repository.dart';
import 'package:ecommerce_app/features/product/domain/usecases/update_product.dart';

class FakeProduct extends Fake implements Product {}
class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late UpdateProductUsecase usecase;
  late MockProductRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeProduct());
  });
  
  setUp(() {
    mockRepository = MockProductRepository();
    usecase = UpdateProductUsecase(mockRepository);
  });

  const tProduct = Product(
    id: '1',
    name: 'Polene bag',
    description: 'Leather sculptured tote bag',
    imageUrl: 'image.jpg',
    price: 540.00,
  );

  test('should return Right(null) when update is successful', () async {
    when(() => mockRepository.updateProduct(any())).thenAnswer((_) async => const Right(null));
    final result = await usecase.call(tProduct);
    expect(result, const Right(null));
    verify(() => mockRepository.updateProduct(tProduct)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return server failure when update fails', () async {
    when(() => mockRepository.updateProduct(any())).thenAnswer((_) async => Left(ServerFailure()));
    final result = await usecase.call(tProduct);
    expect(result, Left(ServerFailure()));
    verify(() => mockRepository.updateProduct(tProduct)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}