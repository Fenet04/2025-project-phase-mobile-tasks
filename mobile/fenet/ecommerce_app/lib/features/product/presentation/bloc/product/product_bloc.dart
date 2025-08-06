import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/create_product.dart';
import '../../../domain/usecases/delete_product.dart';
import '../../../domain/usecases/update_product.dart';
import '../../../domain/usecases/view_all_products.dart';
import '../../../domain/usecases/view_product.dart';

part 'product_event.dart';
part 'product_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ViewAllProductsUsecase viewAllProducts;
  final ViewProductUsecase viewProduct;
  final CreateProductUsecase createProduct;
  final UpdateProductUsecase updateProduct;
  final DeleteProductUsecase deleteProduct;

  ProductBloc({
    required this.viewAllProducts,
    required this.viewProduct,
    required this.createProduct,
    required this.updateProduct,
    required this.deleteProduct,
  }) : super(InitialState()) {
    on<LoadAllProductsEvent>(_onLoadAllProducts);
    on<GetSingleProductEvent>(_onGetSingleProduct);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onLoadAllProducts(
    LoadAllProductsEvent event, Emitter<ProductState> emit) async {
      emit(LoadingState());
      final result = await viewAllProducts();
      result.fold(
        (failure) => emit(ErrorState(_mapFailureToMessage(failure))),
        (products) => emit(LoadedAllProductsState(products)),
      );
    }
  
  Future<void> _onGetSingleProduct(
    GetSingleProductEvent event, Emitter<ProductState> emit) async {
      emit(LoadingState());
      final result = await viewProduct(event.id);
      result.fold(
        (failure) => emit(ErrorState(_mapFailureToMessage(failure))),
        (product) => emit(LoadedSingleProductState(product)),
      );
    }
  
  Future<void> _onCreateProduct(
    CreateProductEvent event, Emitter<ProductState> emit) async {
      emit(LoadingState());
      final result = await createProduct(event.product);
      result.fold(
        (failure) => emit(ErrorState(_mapFailureToMessage(failure))),
        (_) => add(LoadAllProductsEvent()),
      );
    }
  
  Future<void> _onUpdateProduct(
    UpdateProductEvent event, Emitter<ProductState> emit) async {
      emit(LoadingState());
      final result = await updateProduct(event.product);
      result.fold(
        (failure) => emit(ErrorState(_mapFailureToMessage(failure))),
        (_) => add(LoadAllProductsEvent()),
      );
    }
  
  Future<void> _onDeleteProduct(
    DeleteProductEvent event, Emitter<ProductState> emit) async {
      emit(LoadingState());
      final result = await deleteProduct(event.id);
      result.fold(
        (failure) => emit(ErrorState(_mapFailureToMessage(failure))),
        (_) => add(LoadAllProductsEvent()),
      );
    }
  
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}