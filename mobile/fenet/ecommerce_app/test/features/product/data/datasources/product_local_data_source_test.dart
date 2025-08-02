import 'dart:convert';

import 'package:ecommerce_app/core/error/exception.dart';
import 'package:ecommerce_app/features/product/data/datasources/product_local_data_source.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late ProductLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  final tProductModel = ProductModel (
    id: '1',
    name: 'Polene bag',
    description: 'Leather sculptured tote bag',
    imageUrl: 'image.jpg',
    price: 540.00
  );

  final tProductList = [tProductModel];

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = ProductLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getLastProducts', () {
    test('should return List<ProductModel> from SharedPreferences if present', () async {
      when(() => mockSharedPreferences.getString(any<String>())).thenReturn(json.encode([tProductModel.toJson()]));
      final result = await dataSource.getLastProducts();
      verify(() => mockSharedPreferences.getString(CACHED_PRODUCTS));
      expect(result, equals(tProductList));
    });

    test('should throw CacheException when there is not a cached value', () {
      when(() => mockSharedPreferences.getString(any<String>())).thenReturn(null);
      final call = dataSource.getLastProducts;
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('cacheProducts', () {
    test('should call SharedPreferences to cache the data', () async {
      final expectedJsonString = json.encode([tProductModel.toJson()]);
      when(() => mockSharedPreferences.setString(any(), any())).thenAnswer((_) async => true);

      await dataSource.cacheProducts(tProductList);
      verify(() => mockSharedPreferences.setString(CACHED_PRODUCTS, expectedJsonString));
    });
  });
}