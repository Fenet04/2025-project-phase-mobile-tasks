import '../entities/product.dart';

class ViewProductUsecase{
  final List<Product> products;

  ViewProductUsecase(this.products);

  Future<Product?> call(String id) async {
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }
}