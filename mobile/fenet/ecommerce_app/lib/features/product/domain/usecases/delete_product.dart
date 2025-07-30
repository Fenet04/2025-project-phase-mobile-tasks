import '../entities/product.dart';

class DeleteProductUsecase {
  final List<Product> products;

  DeleteProductUsecase(this.products);

  Future<void> call(String id) async {
    products.removeWhere((product) => product.id == id);
  }
}