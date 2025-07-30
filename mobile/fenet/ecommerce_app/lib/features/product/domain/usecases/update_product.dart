import '../entities/product.dart';

class UpdateProductUsecase {
  final List<Product> products;

  UpdateProductUsecase(this.products);

  Future<void> call(Product product) async {
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      products[index] = product;
    }
  }
}