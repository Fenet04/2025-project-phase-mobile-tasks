import 'dart:convert';

import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final tProductModel = ProductModel(
    id: '1',
    name: 'Polene bag',
    description: 'Leather sculptured tote bag',
    imageUrl: 'image.jpg',
    price: 540.00,
  );

  test('should be a subclass of Product entity', () async {
    expect(tProductModel, isA<Product>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON data is correct', () async {
      final Map<String, dynamic> jsonMap = json.decode(fixture('product.json'));
      final result = ProductModel.fromJson(jsonMap);
      expect(result, tProductModel);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () async {
      final result = tProductModel.toJson();
      final expectedMap = {
        'id': '1',
        'name': 'Polene bag',
        'description': 'Leather sculptured tote bag',
        'imageUrl': 'image.jpg',
        'price': 540.00,
      };
      expect(result, expectedMap);
    });
  });
}