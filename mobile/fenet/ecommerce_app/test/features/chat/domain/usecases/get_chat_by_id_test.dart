import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/chat/domain/entities/chat.dart';
import 'package:ecommerce_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:ecommerce_app/features/chat/domain/usecases/get_chat_by_id.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repo;
  late GetChatById usecase;

  setUp(() {
    repo = MockChatRepository();
    usecase =GetChatById(repo);
  });

  test('gets chat by id', () async {
    const chat = Chat(
      id: 'c1',
      user1: User(id: 'u1', name: 'A', email: 'a@a.com', password: ''),
      user2: const User(id: 'u2', name: 'B', email: 'b@b.com', password: ''),
    );

    when(() => repo.getChatById('c1')).thenAnswer((_) async => Right(chat));

    final result = await usecase('c1');

    expect(result, Right(chat));
    verify(() => repo.getChatById('c1')).called(1);
  });

  test('returns failure', () async {
    when(() => repo.getChatById('bad')).thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase('bad');

    expect(result.isLeft(), true);
    verify(() => repo.getChatById('bad')).called(1);
  });
}