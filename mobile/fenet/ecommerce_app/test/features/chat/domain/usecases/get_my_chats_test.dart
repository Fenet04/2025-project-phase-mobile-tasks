import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/chat/domain/entities/chat.dart';
import 'package:ecommerce_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:ecommerce_app/features/chat/domain/usecases/get_my_chats.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repo;
  late GetMyChats usecase;

  setUp(() {
    repo = MockChatRepository();
    usecase = GetMyChats(repo);
  });

  test('returns list of chats from repo', () async {
    final sample = [
      const Chat(
        id: 'c1',
        user1: User(id: 'u1', name: 'A', email: 'a@a.com', password: ''),
        user2: User(id: 'u2', name: 'B', email: 'b@b.com', password: ''),
      ),
    ];
    when(() => repo.getMyChats()).thenAnswer((_) async => Right(sample));

    final result = await usecase();

    expect(result, Right(sample));
    verify(() => repo.getMyChats()).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('return failure', () async {
    when(() => repo.getMyChats()).thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase();
    expect(result.isLeft(), true);
    verify(() => repo.getMyChats()).called(1);
  });
}
