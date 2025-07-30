import '../entities/product.dart';

class CreateProductUsecase {
  final List<Product> products;

  CreateProductUsecase(this.products);

  Future<void> call(Product product) async{
    products.add(product);
  }
}