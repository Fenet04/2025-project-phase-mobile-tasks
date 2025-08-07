import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/exception.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<String> login({required String email, required String password});
  Future<UserModel> register({required String name, required String email, required String password});
  Future<UserModel> getMe({required String token});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  static const baseUrl = 'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v2';

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<String> login({required String email, required String password}) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body)['data']['access_token'];
    } else {
      throw ServerException();
    }
  }

  @override
  Future<UserModel> register({required String name, required String email, required String password}) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      return UserModel.fromJson(json.decode(response.body)['data']);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<UserModel> getMe({required String token}) async {
    final response = await client.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body)['data']);
    } else {
      throw ServerException();
    }
  }
}


