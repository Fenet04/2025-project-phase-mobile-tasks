part of 'chat_messages_bloc.dart';

sealed class ChatMessagesState {
  const ChatMessagesState();
}

class ChatMessagesLoading extends ChatMessagesState {
  const ChatMessagesLoading();
}

class ChatMessagesLoaded extends ChatMessagesState {
  final Chat chat;
  final List<Message> messages;
  final bool sending;
  const ChatMessagesLoaded({
    required this.chat,
    required this.messages,
    this.sending = false,
  });

  ChatMessagesLoaded copyWith({
    Chat? chat,
    List<Message>? messages,
    bool? sending,
  }) =>
      ChatMessagesLoaded(
        chat: chat ?? this.chat,
        messages: messages ?? this.messages,
        sending: sending ?? this.sending,
      );
}

class ChatMessagesError extends ChatMessagesState {
  final String message;
  const ChatMessagesError(this.message);
}
