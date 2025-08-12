import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user.dart';

class Message extends Equatable {
  final String id;
  final String chatId;
  final User sender;
  final String content;
  final String type;

  const Message({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.type,
  });

  @override
  List<Object?> get props => [id, chatId, sender, content, type];
}