import 'dart:io';

class Product {
  String _name;
  String _description;
  double _price;

  Product(this._name,this._description,this._price);

  String get name => _name;
  String get description => _description;
  double get price => _price;

  set name(String newName) => _name = newName;
  set description(String newDescription) => _description = newDescription;
  set price(double newPrice) => _price = newPrice;

  @override
  String toString() {
    return 'Name: $_name\nDescription: $_description\nPrice: $_price birr';
  }
}

class ProductManager {
  final List<Product> _products = [];

  void addProduct() {
    stdout.write('Enter product name: ');
    String name = stdin.readLineSync() ?? '';
    stdout.write('Enter product description: ');
    String description = stdin.readLineSync() ?? '';
    stdout.write('Enter product price: ');
    double? price = double.tryParse(stdin.readLineSync() ?? '');
    if (price == null) {
      print('Invalid price input.');
      return;
    }

    _products.add(Product(name,description,price));
    print('Product added successfully.\n');
  }

  void viewAllProducts() {
    if (_products.isEmpty) {
      print('No products found.\n');
      return;
    }
    for (int i=0; i<_products.length;i++) {
      print('Product #${i+1}');
      print(_products[i]);
      print('----------------');
    }
  }

  void viewProduct(int index) {
    if (_isValidIndex(index)) {
      print(_products[index]);
    } else {
      print('Product not found.\n');
    }
  }

  void editProduct(int index) {
    if (_isValidIndex(index)) {
      stdout.write('Enter new name: ');
      String newName = stdin.readLineSync() ?? '';
      stdout.write('Enter new description: ');
      String newDescription = stdin.readLineSync() ?? '';
      stdout.write('Enter new price: ');
      String priceInput = stdin.readLineSync() ?? '';

      if (newName.isNotEmpty) _products[index].name = newName;
      if (newDescription.isNotEmpty) _products[index].description = newDescription;
      if (priceInput.isNotEmpty) {
        double? newPrice = double.tryParse(priceInput);
        if (newPrice != null) {
          _products[index].price = newPrice;
        } else {
          print('Invalid price. Keeping old value.');
        }
      }
      print('Product updated.\n');
    } else {
      print('Product not found.\n');
    }
  }

  void deleteProduct(int index) {
    if (_isValidIndex(index)) {
      _products.removeAt(index);
      print('Product deleted.\n');
    } else {
      print('Product not found.\n');
    }
  }

  bool _isValidIndex(int index) {
    return index>=0 && index<_products.length;
  }
}

void main() {
  ProductManager manager = ProductManager();
  while (true) {
    print('''
1. Add Product
2. View All Products
3. View a Product
4. Edit a Product
5. Delete a Product
6. Exit
''');

  stdout.write('Choose an option: ');
  String? choice = stdin.readLineSync();

  switch (choice) {
    case '1':
    manager.addProduct();
    break;
    case '2':
    manager.viewAllProducts();
    break;
    case '3':
    stdout.write('Enter product number: ');
    int? index = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
    manager.viewProduct(index-1);
    break;
    case '4':
    stdout.write('Enter product number to edit: ');
    int? index = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
    manager.editProduct(index-1);
    break;
    case '5':
    stdout.write('Enter product number to delete: ');
    int? index = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
    manager.deleteProduct(index-1);
    break;
    case '6':
    print('Exiting...');
    return;
    default:
    print('Invalid option. Try again.\n');
  }
  }
}