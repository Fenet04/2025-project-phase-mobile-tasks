import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/chat/domain/entities/message.dart';
import 'package:ecommerce_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:ecommerce_app/features/chat/domain/usecases/get_chat_messages.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repo;
  late GetChatMessages usecase;

  setUp(() {
    repo = MockChatRepository();
    usecase = GetChatMessages(repo);
  });

  test('gets messages for chat', () async {
    final msgs = [
      Message(
        id: 'm1',
        chatId: 'c1',
        sender: const User(id: 'u1', name: 'A', email: 'a@a.com', password: ''),
        content: 'Hello',
        type: 'text',
      ),
    ];

    when(() => repo.getChatMessages('c1')).thenAnswer((_) async => Right(msgs));

    final result = await usecase('c1');

    expect(result, Right(msgs));
    verify(() => repo.getChatMessages('c1')).called(1);
  });

  test('returns failure', () async {
    when(() => repo.getChatMessages('bad')).thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase('bad');

    expect(result.isLeft(), true);
    verify(() => repo.getChatMessages('bad')).called(1);
  });
}