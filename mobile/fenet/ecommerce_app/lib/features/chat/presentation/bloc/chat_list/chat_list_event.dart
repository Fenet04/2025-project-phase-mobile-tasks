part of 'chat_list_bloc.dart';

sealed class ChatListEvent {
  const ChatListEvent();
}

class ChatListStarted extends ChatListEvent {
  const ChatListStarted();
}

class ChatListRefreshed extends ChatListEvent {
  const ChatListRefreshed();
}
