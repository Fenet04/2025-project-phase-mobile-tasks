import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/message.dart';

class MessageModel extends Message{
  const MessageModel({
    required String id,
    required String chatId,
    required User sender,
    required String content,
    required String type,
  }) : super(
        id: id,
        chatId: chatId,
        sender: sender,
        content: content,
        type: type,
      );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final chat = json['chat'];
    final resolvedChatId = (json['chatId'] ?? (chat is Map<String, dynamic> ? (chat['_id'] ?? chat['id']) : '')).toString();

    return MessageModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      chatId: resolvedChatId,
      sender: UserModel.fromJson(json['sender'] ?? {}),
      content: (json['content'] ?? '').toString(),
      type: (json['type'] ?? 'text').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'sender': (sender is UserModel)
        ? (sender as UserModel).toJson()
        : {
          'id': sender.id,
          'name': sender.name,
          'email': sender.email,
          'password': sender.password,
        },
      'content': content,
      'type': type,
    };
  }
}