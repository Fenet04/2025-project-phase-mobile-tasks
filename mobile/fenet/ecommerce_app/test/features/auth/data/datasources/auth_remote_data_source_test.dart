import 'dart:convert';

import 'package:ecommerce_app/core/error/exception.dart';
import 'package:ecommerce_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ecommerce_app/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockHttpClient;
  late AuthRemoteDataSourceImpl dataSource;

  const baseUrl = 'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v1';

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = AuthRemoteDataSourceImpl(mockHttpClient);
  });

  group('login', () {
    const tEmail = 'user@gmail.com';
    const tPassword = 'userpassword';
    const tToken = 'dummy_token';

    test('should return token when the response code is 201', () async {
      when(() => mockHttpClient.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => http.Response(json.encode({'data': {'access_token': tToken}}), 201));

      final result = await dataSource.login(email: tEmail, password: tPassword);

      expect(result, equals(tToken));
    });

    test('should throw ServerException when the response code is not 201', () async {
      when(() => mockHttpClient.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => http.Response('Something wnet wrong', 400));

      final call = dataSource.login;

      expect(() => call(email: tEmail, password: tPassword), throwsA(isA<ServerException>()));
    });
  });

  group('register', () {
    const tName = 'User';
    const tEmail = 'user@gmail.com';
    const tPassword = 'userpassword';
    const tUserModel = UserModel(id: '1', name: tName, email: tEmail, password: tPassword);

    test('should return UserModel when the response code is 201', () async {
      when(() => mockHttpClient.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => http.Response(json.encode({
        'data': {
          'id': '1',
          'name': tName,
          'email': tEmail,
          'password': tPassword,
        }
      }), 201));

      final result = await dataSource.register(name: tName, email: tEmail, password: tPassword);

      expect(result, equals(tUserModel));
    });

    test('should throw ServerException when the response code is not 201', () async{
      when(() => mockHttpClient.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => http.Response('Error', 400));

      final call = dataSource.register;

      expect(() => call(name: tName, email: tEmail, password: tPassword), throwsA(isA<ServerException>()));
    });
  });

  group('getMe', () {
    const tToken = 'dummy_token';
    const tUserModel = UserModel(id: '1', name: 'Mr. User', email: 'user@gmail.com', password: 'userpassword');

    test('should return UserModel when the response code is 200', () async {
      when(() => mockHttpClient.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization' : 'Bearer $tToken',
        },
      )).thenAnswer((_) async => http.Response(json.encode({
        'data': {
          'id': '1',
          'name': 'Mr. User',
          'email': 'user@gmail.com',
          'password': 'userpassword',
        }
      }), 200));

      final result = await dataSource.getMe(token: tToken);

      expect(result, equals(tUserModel));
    });

    test('should throw ServerException when the response code is not 200', () async {
      when(() => mockHttpClient.get(
        Uri.parse('$baseUrl/users/me'),
        headers: any(named: 'headers'),
      )).thenAnswer((_) async => http.Response('Unauthorized', 401));

      final call = dataSource.getMe;

      expect(() => call(token: tToken), throwsA(isA<ServerException>()));
    });
  });
}