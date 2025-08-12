import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/usecases/get_my_chats.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetMyChats getMyChats;

  ChatListBloc(this.getMyChats) : super(const ChatListLoading()) {
    on<ChatListStarted>(_load);
    on<ChatListRefreshed>(_load);
  }

  Future<void> _load(ChatListEvent event, Emitter<ChatListState> emit) async {
    emit(const ChatListLoading());
    final res = await getMyChats();
    res.fold(
      (f) => emit(ChatListError(f.message)),
      (list) => emit(ChatListLoaded(list)),
    );
  }
}
