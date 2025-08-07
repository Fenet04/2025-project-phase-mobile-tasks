import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_app/core/error/exception.dart';
import 'package:ecommerce_app/features/auth/data/datasources/auth_local_data_source.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late AuthLocalDataSourceImpl dataSource;

  const tToken = 'dummy_token';

  setUp(() {
    mockPrefs = MockSharedPreferences();
    dataSource = AuthLocalDataSourceImpl(mockPrefs);
  });

  group('cacheToken', () {
    test('should store token when SharedPreferences returns true', () async {
      when(() => mockPrefs.setString(cachedTokenKey, tToken)).thenAnswer((_) async => true);

      await dataSource.cacheToken(tToken);

      verify(() => mockPrefs.setString(cachedTokenKey, tToken)).called(1);
    });

    test('should throw CacheException when SharedPreferences return false', () async {
      when(() => mockPrefs.setString(cachedTokenKey, tToken)).thenAnswer((_) async => false);

      final call = dataSource.cacheToken;

      expect(() => call(tToken), throwsA(isA<CacheException>()));
    });
  });

  group('getCachedToken', () {
    test('should return token if present in sharedPreferences', () async {
      when(() => mockPrefs.getString(cachedTokenKey)).thenReturn(tToken);

      final result = await dataSource.getCachedToken();

      expect(result, equals(tToken));
      verify(() => mockPrefs.getString(cachedTokenKey)).called(1);
    });

    test('should return null if token is not present', () async {
      when(() => mockPrefs.getString(cachedTokenKey)).thenReturn(null);

      final result = await dataSource.getCachedToken();

      expect(result, isNull);
    });
  });

  group('removeToken', () {
    test('should call remove on SharedPrefernces', () async {
      when(() => mockPrefs.remove(cachedTokenKey)).thenAnswer((_) async => true);

      await dataSource.removeToken();

      verify(() => mockPrefs.remove(cachedTokenKey)).called(1);
    });
  });
}