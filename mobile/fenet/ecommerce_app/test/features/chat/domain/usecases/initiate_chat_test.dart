import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/chat/domain/entities/chat.dart';
import 'package:ecommerce_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:ecommerce_app/features/chat/domain/usecases/initiate_chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repo;
  late InitiateChat usecase;

  setUp(() {
    repo = MockChatRepository();
    usecase = InitiateChat(repo);
  });

  test('initiates chat with userId', () async {
    final chat = Chat(
      id: 'CNew',
      user1: const User(id: 'me', name: 'Me', email: 'me@me.com', password: ''),
      user2: const User(id: 'target', name: 'T', email: 't@t.com', password: ''),
    );

    when(() => repo.initiateChat('target')).thenAnswer((_) async => Right(chat));

    final result = await usecase('target');

    expect(result, Right(chat));
    verify(() => repo.initiateChat('target')).called(1);
  });

  test('return failure', () async {
    when(() => repo.initiateChat('bad')).thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase('bad');

    expect(result.isLeft(), true);
    verify(() => repo.initiateChat('bad')).called(1);
  });
}