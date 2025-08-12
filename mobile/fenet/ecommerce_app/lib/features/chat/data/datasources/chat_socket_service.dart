import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/message_model.dart';

abstract class ChatSocketService {
  Future<void> connect({required String token});
  bool get isConnected;
  Future<MessageModel> sendMessage({
    required String chatId,
    required String content,
    String type = 'text',
  });

  Stream<MessageModel> onMessageDelivered();
  Stream<MessageModel> onMessageReceived();
  void dispose();
}

class ChatSocketServiceImpl implements ChatSocketService {
  final String baseUrl;
  io.Socket? _socket;

  final _deliveredCtrl = StreamController<MessageModel>.broadcast();
  final _receivedCtrl  = StreamController<MessageModel>.broadcast();

  ChatSocketServiceImpl({
    this.baseUrl = 'https://g5-flutter-learning-path-be-tvum.onrender.com',
  });

  @override
  Future<void> connect({required String token}) async {
    if (isConnected) return;

    final opts = io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setAuth({'Authorization': 'Bearer $token', 'token': token})
        .setQuery({'token': token})
        .build();

    _socket = io.io(baseUrl, opts);

    _socket!.on('connect', (_) => print('[socket] connected: ${_socket!.id}'));
    _socket!.on('disconnect', (_) => print('[socket] disconnected'));
    _socket!.on('connect_error', (e) => print('[socket] connect_error: $e'));
    _socket!.on('error', (e) => print('[socket] error: $e'));
    _socket!.on('exception', (e) => print('[socket] exception: $e'));

    _socket!.on('message:delivered', (data) {
      try {
        final msg = MessageModel.fromJson(Map<String, dynamic>.from(data as Map));
        _deliveredCtrl.add(msg);
      } catch (e) {
        print('[socket] parse delivered error: $e');
      }
    });

    _socket!.on('message:received', (data) {
      try {
        final msg = MessageModel.fromJson(Map<String, dynamic>.from(data as Map));
        _receivedCtrl.add(msg);
      } catch (e) {
        print('[socket] parse received error: $e');
      }
    });

    final completer = Completer<void>();
    void onOk(_) { _socket?.off('connect', onOk); _socket?.off('connect_error'); completer.complete(); }
    void onErr(e){ _socket?.off('connect', onOk); _socket?.off('connect_error', onErr); completer.completeError(StateError('Socket connect_error: $e')); }

    _socket!.on('connect', onOk);
    _socket!.on('connect_error', onErr);
    _socket!.connect();

    await completer.future.timeout(const Duration(seconds: 10));
  }

  @override
  bool get isConnected => _socket?.connected == true;

  @override
  Future<MessageModel> sendMessage({
    required String chatId,
    required String content,
    String type = 'text',
  }) async {
    if (!isConnected) {
      throw StateError('Socket not connected');
    }

    final completer = Completer<MessageModel>();

    late void Function(dynamic) deliveredHandler;
    late void Function(dynamic) exceptionHandler;

    deliveredHandler = (data) {
      try {
        final msg = MessageModel.fromJson(Map<String, dynamic>.from(data as Map));
        if (msg.chatId == chatId && msg.content == content) {
          _socket?.off('message:delivered', deliveredHandler);
          _socket?.off('exception', exceptionHandler);
          completer.complete(msg);
        }
      } catch (e) {
      }
    };

    exceptionHandler = (data) {
      try {
        final payload = data is Map ? data : (data as List).length > 1 ? data[1] : null;
        final message = (payload is Map && payload['message'] != null)
            ? payload['message'].toString()
            : 'Unknown server error';
        _socket?.off('message:delivered', deliveredHandler);
        _socket?.off('exception', exceptionHandler);
        if (!completer.isCompleted) {
          completer.completeError(StateError('Server exception: $message'));
        }
      } catch (_) {}
    };

    _socket!.on('message:delivered', deliveredHandler);
    _socket!.on('exception', exceptionHandler);

    _socket!.emit('message:send', {
      'chatId': chatId,
      'content': content,
      'type': type,
    });

    return completer.future.timeout(
      const Duration(seconds: 25),
      onTimeout: () {
        _socket?.off('message:delivered', deliveredHandler);
        _socket?.off('exception', exceptionHandler);
        throw StateError('Timed out waiting for message:delivered');
      },
    );
  }

  @override
  Stream<MessageModel> onMessageDelivered() => _deliveredCtrl.stream;

  @override
  Stream<MessageModel> onMessageReceived() => _receivedCtrl.stream;

  @override
  void dispose() {
    _socket?.dispose();
    _socket = null;
    _deliveredCtrl.close();
    _receivedCtrl.close();
  }
}

