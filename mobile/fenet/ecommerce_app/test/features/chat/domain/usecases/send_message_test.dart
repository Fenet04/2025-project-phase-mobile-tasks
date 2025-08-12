import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/chat/domain/entities/message.dart';
import 'package:ecommerce_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:ecommerce_app/features/chat/domain/usecases/send_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repo;
  late SendMessage usecase;

  setUp(() {
    repo = MockChatRepository();
    usecase = SendMessage(repo);
  });

  test('sends message via repo and returns delivered message', () async {
    final delivered = Message(
      id: 'm1',
      chatId: 'c1',
      sender: const User(id: 'me', name: 'Me', email: 'me@me.com', password: ''),
      content: 'Hello',
      type: 'text',
    );

    when(() => repo.sendMessage(chatId: 'c1', content: 'Hello', type: 'text'))
      .thenAnswer((_) async => Right(delivered));
    
    final result = await usecase(chatId: 'c1', content: 'Hello');

    expect(result, Right(delivered));
    verify(() => repo.sendMessage(chatId: 'c1', content: 'Hello', type: 'text')).called(1);
  });

  test('returns failure on error', () async {
    when(() => repo.sendMessage(chatId: 'c1', content: 'Hello', type: 'text'))
      .thenAnswer((_) async => Left(ServerFailure()));

      final result = await usecase(chatId: 'c1', content: 'Hello');

      expect(result.isLeft(), true);
      verify(() => repo.sendMessage(chatId: 'c1', content: 'Hello', type: 'text'));
  });
}