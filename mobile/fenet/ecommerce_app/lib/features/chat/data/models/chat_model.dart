import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/chat.dart';

class ChatModel extends Chat {
  const ChatModel({
    required String id,
    required User user1,
    required User user2,
  }) : super(id: id, user1: user1, user2: user2);

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      user1: UserModel.fromJson(json['user1'] ?? {}),
      user2: UserModel.fromJson(json['user2'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1': (user1 as UserModel).toJson(),
      'user2': (user2 as UserModel).toJson(),
    };
  }
}