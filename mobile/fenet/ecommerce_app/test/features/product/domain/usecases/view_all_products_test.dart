import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/product/domain/entities/product.dart';
import 'package:ecommerce_app/features/product/domain/repositories/product_repository.dart';
import 'package:ecommerce_app/features/product/domain/usecases/view_all_products.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late ViewAllProductsUsecase usecase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    usecase = ViewAllProductsUsecase(mockRepository);
  });

  final tProducts = [
    const Product(
      id: '1',
      name: 'Polene bag',
      description: 'Leather sculptured tote bag',
      imageUrl: 'image.jpg',
      price: 540.00,
    ),
    const Product(
      id: '2',
      name: 'Longchamp bag',
      description: 'Foldable spacious tote bag',
      imageUrl: 'image2.jpg',
      price: 250.00,
    ),
  ];

  test('should return list of products from the repository', () async {
    when(() => mockRepository.getAllProducts()).thenAnswer((_) async => Right(tProducts));
    final result = await usecase();
    expect(result, Right(tProducts));
    verify(() => mockRepository.getAllProducts()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.getAllProducts()).thenAnswer((_) async => Left(ServerFailure()));
    final result =await usecase();
    expect(result, Left(ServerFailure()));
    verify(() => mockRepository.getAllProducts()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}