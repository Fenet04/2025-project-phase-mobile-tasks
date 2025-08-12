part of 'chat_messages_bloc.dart';

sealed class ChatMessagesEvent {
  const ChatMessagesEvent();
}

class ChatMessagesStarted extends ChatMessagesEvent {
  final String chatId;
  const ChatMessagesStarted(this.chatId);
}

class ChatMessageSubmitted extends ChatMessagesEvent {
  final String chatId;
  final String text;
  const ChatMessageSubmitted({required this.chatId, required this.text});
}

class _ChatMessageDeliveredEvt extends ChatMessagesEvent {
  final Message message;
  const _ChatMessageDeliveredEvt(this.message);
}

class _ChatMessageReceivedEvt extends ChatMessagesEvent {
  final Message message;
  const _ChatMessageReceivedEvt(this.message);
}
