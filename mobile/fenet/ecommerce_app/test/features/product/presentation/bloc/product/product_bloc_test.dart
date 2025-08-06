import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/product/domain/entities/product.dart';
import 'package:ecommerce_app/features/product/domain/usecases/create_product.dart';
import 'package:ecommerce_app/features/product/domain/usecases/delete_product.dart';
import 'package:ecommerce_app/features/product/domain/usecases/update_product.dart';
import 'package:ecommerce_app/features/product/domain/usecases/view_all_products.dart';
import 'package:ecommerce_app/features/product/domain/usecases/view_product.dart';
import 'package:ecommerce_app/features/product/presentation/bloc/product/product_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateProductUsecase extends Mock implements CreateProductUsecase {}
class MockDeleteProductUsecase extends Mock implements DeleteProductUsecase {}
class MockUpdateProductUsecase extends Mock implements UpdateProductUsecase {}
class MockViewAllProductsUsecase extends Mock implements ViewAllProductsUsecase {}
class MockViewProductUsecase extends Mock implements ViewProductUsecase {} 

void main() {
  late ProductBloc bloc;
  late MockCreateProductUsecase create;
  late MockDeleteProductUsecase delete;
  late MockUpdateProductUsecase update;
  late MockViewAllProductsUsecase viewAll;
  late MockViewProductUsecase viewOne;

  const tProduct = Product(
    id: '1',
    name: 'Polene bag',
    description: 'Leather sculptured tote bag',
    imageUrl: 'image.jpg',
    price: 540.00, 
  );

  setUp(() {
    create = MockCreateProductUsecase();
    delete = MockDeleteProductUsecase();
    update = MockUpdateProductUsecase();
    viewAll = MockViewAllProductsUsecase();
    viewOne = MockViewProductUsecase();
    bloc = ProductBloc(
      createProduct: create,
      deleteProduct: delete, 
      updateProduct: update,
      viewAllProducts: viewAll,
      viewProduct: viewOne,
    );

    registerFallbackValue(tProduct);
  });

  group('LoadAllProductEvent', () {
    blocTest<ProductBloc, ProductState>(
      'emits [LoadingState, LoadedAllProductState] on success',
      build: () {
        when(() => viewAll()).thenAnswer((_) async => Right([tProduct]));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadAllProductsEvent()),
      expect: () => [LoadingState(), LoadedAllProductsState([tProduct])],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [LoadingState, ErrorState] on failure',
      build: () {
        when(() => viewAll()).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadAllProductsEvent()),
      expect: () => [LoadingState(), ErrorState('Server Failure')],
    );
  });

  group('GetSingleProductEvent', () {
    blocTest<ProductBloc, ProductState>(
      'emits [LoadingState, LoadedSingleProductState] on sucess',
      build: () {
        when(() => viewOne('1')).thenAnswer((_) async => Right(tProduct));
        return bloc;
      },
      act: (bloc) => bloc.add(GetSingleProductEvent('1')),
      expect: () => [LoadingState(), LoadedSingleProductState(tProduct)],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [LoadingState, ErrorState] on failure',
      build: () {
        when(() => viewOne('1')).thenAnswer((_) async => Left(CacheFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetSingleProductEvent('1')),
      expect: () => [LoadingState(), ErrorState('Cache Failure')],
    );
  });

  group('CreateProductEvent', () {
    blocTest<ProductBloc, ProductState>(
      'emits [LoadingState] and then reloads all products on success',
      build: () {
        when(() => create(tProduct)).thenAnswer((_) async => const Right(null));
        when(() => viewAll()).thenAnswer((_) async => Right([tProduct]));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateProductEvent(tProduct)),
      expect: () => [LoadingState(), LoadedAllProductsState([tProduct])],
    );
  });

  group('UpdateProductEvent', () {
    blocTest<ProductBloc, ProductState>(
      'emits [LoadingState] and then reloads all products on success',
      build: () {
        when(() => update(tProduct)).thenAnswer((_) async => const Right(null));
        when(() => viewAll()).thenAnswer((_) async => Right([tProduct]));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateProductEvent(tProduct)),
      expect: () => [LoadingState(), LoadedAllProductsState([tProduct])],
    );
  });

  group('DeleteProductEvent', () {
    blocTest<ProductBloc, ProductState>(
      'emits [LoadingState] and then reloads all products on success',
      build: () {
        when(() => delete('1')).thenAnswer((_) async => const Right(null));
        when(() => viewAll()).thenAnswer((_) async => Right([tProduct]));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteProductEvent('1')),
      expect: () => [LoadingState(), LoadedAllProductsState([tProduct])],
    );
  });
}