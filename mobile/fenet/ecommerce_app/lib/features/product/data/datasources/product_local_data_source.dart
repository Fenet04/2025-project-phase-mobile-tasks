import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exception.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getLastProducts();
  Future<void> cacheProducts(List<ProductModel> products);
}

const String CACHED_PRODUCTS = 'CACHED_PRODUCTS';

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProductLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<ProductModel>> getLastProducts() {
    final jsonString = sharedPreferences.getString(CACHED_PRODUCTS);
    if (jsonString != null) {
      final List decodedJson = json.decode(jsonString);
      final products = decodedJson.map((e) => ProductModel.fromJson(e)).toList();
      return Future.value(products);
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> productsToCache) {
    final jsonString = json.encode(productsToCache.map((p) => p.toJson()).toList());
    return sharedPreferences.setString(CACHED_PRODUCTS, jsonString);
  }
}