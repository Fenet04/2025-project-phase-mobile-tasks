import 'package:ecommerce_app/core/platform/network_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mocktail/mocktail.dart';

class MockInternetConnectionChecker extends Mock implements InternetConnectionChecker {}

void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnectionChecker mockConnectionChecker;

  setUp(() {
    mockConnectionChecker = MockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(mockConnectionChecker);
  });

  group('isConnected', () {
    test('should forward the call to InternetConnectionChecker.hasConnection', () async {
      final tHasConnectionFuture = Future.value(true);
      when(() => mockConnectionChecker.hasConnection).thenAnswer((_) => tHasConnectionFuture);
      
      final result = networkInfo.isConnected;

      verify(() => mockConnectionChecker.hasConnection);
      expect(result, tHasConnectionFuture);
    });
  });
}