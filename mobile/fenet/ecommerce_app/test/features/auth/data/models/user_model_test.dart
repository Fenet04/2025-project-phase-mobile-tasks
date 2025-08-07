import 'package:ecommerce_app/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tUserModel = UserModel(
    id: '1',
    name: 'Mr. User',
    email: 'user@gmail.com',
    password: 'userpassword',
  );

  final tJson = {
    'id': '1',
    'name': 'Mr. User',
    'email': 'user@gmail.com',
    'password': 'userpassword',
  };

  group('UserModel', () {
    test('fromJson should return a valid model', () {
      final result = UserModel.fromJson(tJson);
      expect(result, tUserModel);
    });

    test('toJson should return a valid JSON map', () {
      final result = tUserModel.toJson();
      expect(result, tJson);
    });

    test('props should contain the correct values', () {
      expect(tUserModel.props, ['1', 'Mr. User', 'user@gmail.com', 'userpassword']);
    });
  });
}