import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/chat_socket_service.dart';
import '../../../domain/entities/chat.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/usecases/get_chat_by_id.dart';
import '../../../domain/usecases/get_chat_messages.dart';
import '../../../domain/usecases/send_message.dart';

part 'chat_messages_event.dart';
part 'chat_messages_state.dart';

class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessagesState> {
  final GetChatById getChatById;
  final GetChatMessages getChatMessages;
  final SendMessage sendMessage;
  final ChatSocketService socket;
  final String Function() tokenProvider;

  StreamSubscription<Message>? _deliveredSub;
  StreamSubscription<Message>? _receivedSub;

  ChatMessagesBloc({
    required this.getChatById,
    required this.getChatMessages,
    required this.sendMessage,
    required this.socket,
    required this.tokenProvider,
  }) : super(const ChatMessagesLoading()) {
    on<ChatMessagesStarted>(_onStart);
    on<ChatMessageSubmitted>(_onSubmit);
    on<_ChatMessageDeliveredEvt>(_onIncoming);
    on<_ChatMessageReceivedEvt>(_onIncoming);
  }

  Future<void> _onStart(ChatMessagesStarted e, Emitter<ChatMessagesState> emit) async {
    emit(const ChatMessagesLoading());

    try {
      if (!socket.isConnected) {
        await socket.connect(token: tokenProvider());
      }
    } catch (_) {}

    final chatRes = await getChatById(e.chatId);
    final msgsRes = await getChatMessages(e.chatId);

    if (chatRes.isLeft() || msgsRes.isLeft()) {
      emit(const ChatMessagesError('Failed to load chat'));
      return;
    }

    final chat = chatRes.getOrElse(() => throw StateError('no chat'));
    final messages = msgsRes.getOrElse(() => <Message>[]);

    _deliveredSub?.cancel();
    _receivedSub?.cancel();
    _deliveredSub = socket.onMessageDelivered().listen((m) {
      if (m.chatId == e.chatId) add(_ChatMessageDeliveredEvt(m));
    });
    _receivedSub = socket.onMessageReceived().listen((m) {
      if (m.chatId == e.chatId) add(_ChatMessageReceivedEvt(m));
    });

    emit(ChatMessagesLoaded(chat: chat, messages: messages));
  }

  Future<void> _onSubmit(ChatMessageSubmitted e, Emitter<ChatMessagesState> emit) async {
    final s = state;
    if (s is! ChatMessagesLoaded) return;
    final text = e.text.trim();
    if (text.isEmpty) return;

    emit(s.copyWith(sending: true));
    final res = await sendMessage(chatId: e.chatId, content: text, type: 'text');
    res.fold(
      (_) => emit(s.copyWith(sending: false)),
      (msg) => emit(s.copyWith(messages: [...s.messages, msg], sending: false)),
    );
  }

  void _onIncoming(dynamic e, Emitter<ChatMessagesState> emit) {
    final s = state;
    if (s is! ChatMessagesLoaded) return;
    final m = (e as dynamic).message as Message;
    emit(s.copyWith(messages: [...s.messages, m]));
  }

  @override
  Future<void> close() {
    _deliveredSub?.cancel();
    _receivedSub?.cancel();
    return super.close();
  }
}
