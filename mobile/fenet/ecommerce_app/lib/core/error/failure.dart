import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  ServerFailure({String message = 'Server failure'}) : super(message: message);
}

class CacheFailure extends Failure {
  CacheFailure({String message = 'Cache failure'}) : super(message: message);
} 

class NetworkFailure extends Failure {
  NetworkFailure({String message = 'No internet connection'}) : super(message: message);
}