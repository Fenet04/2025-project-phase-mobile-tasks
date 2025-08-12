import 'package:ecommerce_app/features/auth/data/models/user_model.dart';
import 'package:ecommerce_app/features/chat/data/datasources/chat_local_data_source.dart';
import 'package:ecommerce_app/features/chat/data/models/chat_model.dart';
import 'package:ecommerce_app/features/chat/data/models/message_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late ChatLocalDataSourceImpl local;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    local = ChatLocalDataSourceImpl(prefs);
  });

  test('cacheMyChats & getCachedMyChats round-trip', () async {
    final u1 = const UserModel(id: 'u1', name: 'A', email: 'a@a.com', password: '');
    final u2 = const UserModel(id: 'u2', name: 'B', email: 'b@b.com', password: '');
    final chats = [ChatModel(id: 'c1', user1: u1, user2: u2)];

    await local.cacheMyChats(chats);
    final got = await local.getCachedMyChats();

    expect(got.map((c) => c.id).toList(), ['c1']);
    expect(got.first.user1.id, 'u1');
  });

  test('cacheChatMessages & getCachedChatMessages round-trip', () async {
    final sender = const UserModel(id: 'u1', name: 'A', email: 'a@a.com', password: '');
    final messages = [
      MessageModel(id: 'm1', chatId: 'c1', sender: sender, content: 'Hello', type: 'text'),
    ];

    await local.cacheChatMessages('c1', messages);
    final got = await local.getCachedChatMessages('c1');

    expect(got.map((m) => m.id).toList(), ['m1']);
    expect(got.first.chatId, 'c1');
  });

  test('upsertCachedMessage inserts then updates correctly', () async {
    final sender = const UserModel(id: 'u1', name: 'A', email: 'a@a.com', password: '');
    final m1 = MessageModel(id: 'm1', chatId: 'c1', sender: sender, content: 'Hello', type: 'text');

    await local.upsertCachedMessage('c1', m1);
    var got = await local.getCachedChatMessages('c1');
    expect(got.length, 1);
    expect(got.first.content, 'Hello');

    final m1b = MessageModel(id: 'm1', chatId: 'c1', sender: sender, content: 'Hello!!', type: 'text');
    await local.upsertCachedMessage('c1', m1b);
    got = await local.getCachedChatMessages('c1');
    expect(got.length, 1);
    expect(got.first.content, 'Hello!!');
  });

  test('clearChatCache removes messages', () async {
    final sender = const UserModel(id: 'u1', name: 'A', email: 'a@a.com', password: '');
    final m1 = MessageModel(id: 'm1', chatId: 'c1', sender: sender, content: 'Hi', type: 'text');

    await local.upsertCachedMessage('c1', m1);
    await local.clearChatCache('c1');

    expect(local.getCachedChatMessages('c1'), throwsA(isA<Exception>()));
  });
}
