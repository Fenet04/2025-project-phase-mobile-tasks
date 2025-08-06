import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/product/domain/entities/product.dart';
import 'package:ecommerce_app/features/product/domain/repositories/product_repository.dart';
import 'package:ecommerce_app/features/product/domain/usecases/view_product.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late ViewProductUsecase usecase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    usecase = ViewProductUsecase(mockRepository);
  });

  final tId = '1';
  final tProduct = Product(
    id: tId,
    name: 'Polene bag',
    description: 'Leather sculptured tote bag',
    imageUrl: 'image.jpg',
    price: 540.00,
  );

  test('should return product from repository when successful', () async {
    when(() => mockRepository.getProduct(tId)).thenAnswer((_) async => Right(tProduct));
    final result = await usecase(tId);
    expect(result, Right(tProduct));
    verify(() => mockRepository.getProduct(tId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure from repository when something goes wrong', () async {
    when(() => mockRepository.getProduct(tId)).thenAnswer((_) async => Left(ServerFailure()));
    final result = await usecase(tId);
    expect(result, Left(ServerFailure()));
    verify(() => mockRepository.getProduct(tId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}