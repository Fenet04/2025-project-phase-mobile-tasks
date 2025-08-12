import 'package:ecommerce_app/features/auth/data/models/user_model.dart';
import 'package:ecommerce_app/features/chat/data/models/message_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessageModel', () {
    test('fromJson maps _id, nested sender, and embedded chat id', () {
      final json = {
        '_id': 'm1',
        'sender': {'_id': 'u1', 'name': 'A', 'email': 'a@a.com'},
        'chat': {
          '_id': 'c1',
          'user1': {'_id': 'u1', 'name': 'A', 'email': 'a@a.com'},
          'user2': {'_id': 'u2', 'name': 'B', 'email': 'b@b.com'},
        },
        'content': 'Hello',
        'type': 'text',
      };

      final model = MessageModel.fromJson(json);

      expect(model.id, 'm1');
      expect(model.chatId, 'c1');
      expect(model.sender.id, 'u1');
      expect(model.content, 'Hello');
      expect(model.type, 'text');
    });

    test('toJson returns flat chatId and sender json', () {
      final sender = const UserModel(id: 'u1', name: 'A', email: 'a@a.com', password: '');
      final model = MessageModel(
        id: 'm1',
        chatId: 'c1',
        sender: sender,
        content: 'Hello',
        type: 'text',
      );

      final map = model.toJson();

      expect(map['id'], 'm1');
      expect(map['chatId'], 'c1');
      expect(map['sender']['id'], 'u1');
      expect(map['content'], 'Hello');
      expect(map['type'], 'text');
    });
  });
}
