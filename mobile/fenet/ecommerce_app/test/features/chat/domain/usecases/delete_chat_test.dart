import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:ecommerce_app/features/chat/domain/usecases/delete_chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository repo;
  late DeleteChat usecase;

  setUp(() {
    repo = MockChatRepository();
    usecase = DeleteChat(repo);
  });

  test('deletes chat by id', () async {
    when(() => repo.deleteChat('c1')).thenAnswer((_) async => const Right(null));

    final result = await usecase('c1');

    expect(result, const Right(null));
    verify(() => repo.deleteChat('c1')).called(1);
  });

  test('return failure', () async {
    when(() => repo.deleteChat('bad')).thenAnswer((_) async => Left(ServerFailure()));

    final result = await usecase('bad');

    expect(result.isLeft(), true);
    verify(() => repo.deleteChat('bad')).called(1);
  });
}