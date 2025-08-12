part of 'chat_list_bloc.dart';

sealed class ChatListState {
  const ChatListState();
}

class ChatListLoading extends ChatListState {
  const ChatListLoading();
}

class ChatListLoaded extends ChatListState {
  final List<Chat> chats;
  const ChatListLoaded(this.chats);
}

class ChatListError extends ChatListState {
  final String message;
  const ChatListError(this.message);
}
