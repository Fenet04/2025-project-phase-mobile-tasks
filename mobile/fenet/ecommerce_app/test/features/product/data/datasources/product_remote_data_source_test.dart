import 'dart:convert';
import 'dart:core';

import 'package:ecommerce_app/core/error/exception.dart';
import 'package:ecommerce_app/features/product/data/datasources/product_remote_data_source.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late ProductRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://dummy.com'));
  });
  
  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = ProductRemoteDataSourceImpl(client: mockHttpClient);
  });

  final tProductModel = ProductModel(
    id: '1',
    name: 'Polene bag',
    description: 'Leather sculptured tote bag',
    imageUrl: 'image.jpg',
    price: 540.00,
  );

  final List<ProductModel> tProductList = [tProductModel];

  group('getAllProducts', () {
    test('should perform GET and return List<ProductModel> on success', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response(
        json.encode([tProductModel.toJson()]),
        200,
        ));
      final result = await dataSource.getAllProducts();
      expect(result, equals(tProductList));
    });

    test('should throw ServerException on non-200 response', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response('Error', 404));
      expect(() => dataSource.getAllProducts(), throwsA(isA<ServerException>()));
    });
  });

  group('getProduct', () {
    test('should perform GET and return ProductModel on success', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response(
        json.encode(tProductModel.toJson()),
        200,
      ));
      final result = await dataSource.getProduct('1');
      expect(result, equals(tProductModel));
    });

    test('should throw ServerException on non-200 response', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response('Error', 404));
      expect(() => dataSource.getProduct('1'), throwsA(isA<ServerException>()));
    });
  });

  group('createProduct', () {
    test('should perform POST and return void on success', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
      .thenAnswer((_) async => http.Response('', 201));

      await dataSource.createProduct(tProductModel);
      verify(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: json.encode(tProductModel.toJson()))).called(1);
    });

    test('should thow ServerException on non-201 response', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
      .thenAnswer((_) async => http.Response('Error', 400));

      expect(() => dataSource.createProduct(tProductModel), throwsA(isA<ServerException>()));
    });
  });

  group('updateProduct', () {
    test('should perform PUT and return void on success', () async {
      when(() => mockHttpClient.put(any(), headers: any(named: 'headers'), body: any(named: 'body')))
      .thenAnswer((_) async => http.Response('', 200));

      await dataSource.updateProduct(tProductModel);
      verify(() => mockHttpClient.put(any(), headers: any(named: 'headers'), body: json.encode(tProductModel.toJson()))).called(1);
    });

    test('should throw ServerException on non-200 response', () async {
      when(() => mockHttpClient.put(any(), headers: any(named: 'headers'), body: any(named: 'body')))
      .thenAnswer((_) async => http.Response('Error', 500));

      expect(() => dataSource.updateProduct(tProductModel), throwsA(isA<ServerException>()));
    });
  });

  group('deletProduct', () {
    test('should perform DELETE and return void on success', () async {
      when(() => mockHttpClient.delete(any(), headers: any(named: 'headers')))
      .thenAnswer((_) async => http.Response('', 200));

      await dataSource.deleteProduct('1');
      verify(() => mockHttpClient.delete(any(), headers: any(named: 'headers'))).called(1);
    });

    test('should throw ServerException on non-200 response', () async {
      when(() => mockHttpClient.delete(any(), headers: any(named: 'headers')))
      .thenAnswer((_) async => http.Response('Error', 404));

      expect(() => dataSource.deleteProduct('1'), throwsA(isA<ServerException>()));
    });
  });
}