import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exception.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getCachedToken();
  Future<void> removeToken();
}

const cachedTokenKey = 'CACHED_ACCESS_TOKEN';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheToken(String token) async {
    final result = await sharedPreferences.setString(cachedTokenKey, token);
    if(!result) throw CacheException();
  }

  @override
  Future<String?> getCachedToken() async {
    return sharedPreferences.getString(cachedTokenKey);
  }

  @override
  Future<void> removeToken() async {
    await sharedPreferences.remove(cachedTokenKey);
  }
}