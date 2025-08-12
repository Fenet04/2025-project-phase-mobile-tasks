import 'package:ecommerce_app/features/auth/data/models/user_model.dart';
import 'package:ecommerce_app/features/chat/data/models/chat_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatModel', () {
    test('fromJson maps _id and nested users', () {
      final json = {
        '_id': 'c1',
        'user1': {'_id': 'u1', 'name': 'A', 'email': 'a@a.com'},
        'user2': {'_id': 'u2', 'name': 'B', 'email': 'b@b.com'},
      };

      final model = ChatModel.fromJson(json);

      expect(model.id, 'c1');
      expect(model.user1.id, 'u1');
      expect(model.user2.id, 'u2');
    });

    test('toJson returns id and nested user json', () {
      final u1 = const UserModel(id: 'u1', name: 'A', email: 'a@a.com', password: '');
      final u2 = const UserModel(id: 'u2', name: 'B', email: 'b@b.com', password: '');
      final model = ChatModel(id: 'c1', user1: u1, user2: u2);

      final map = model.toJson();

      expect(map['id'], 'c1');
      expect(map['user1']['id'], 'u1');
      expect(map['user2']['id'], 'u2');
    });
  });
}
