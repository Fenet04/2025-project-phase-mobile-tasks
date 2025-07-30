import '../entities/product.dart';

class ViewAllProductsUsecase {
  final List<Product> products;

  ViewAllProductsUsecase(this.products);
  
  Future<List<Product>> call() async {
    return products;
  }
}