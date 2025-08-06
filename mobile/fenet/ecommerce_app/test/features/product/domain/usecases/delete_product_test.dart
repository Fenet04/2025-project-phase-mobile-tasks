import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/product/domain/repositories/product_repository.dart';
import 'package:ecommerce_app/features/product/domain/usecases/delete_product.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late DeleteProductUsecase usecase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    usecase = DeleteProductUsecase(mockRepository);
  });

  const tId = '1';
  test('should delete product by id from the repository', () async {
    when(() => mockRepository.deleteProduct(any())).thenAnswer((_) async => const Right(null));
    final result = await usecase.call(tId);
    expect(result, const Right(null));
    verify(() => mockRepository.deleteProduct(tId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return server failure when delete fails', () async {
    when(() => mockRepository.deleteProduct(any())).thenAnswer((_) async => Left(ServerFailure()));
    final result = await usecase.call(tId);
    expect(result, Left(ServerFailure()));
    verify(() => mockRepository.deleteProduct(tId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}