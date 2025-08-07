import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/platform/network_info.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/get_me.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/register.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/sign_in_page.dart';
import 'features/auth/presentation/pages/sign_up_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final client = http.Client();
  final sharedPreferences = await SharedPreferences.getInstance();
  final networkInfo = NetworkInfoImpl(InternetConnectionChecker.createInstance());

  final remoteDataSource = AuthRemoteDataSourceImpl(client);
  final localDataSource = AuthLocalDataSourceImpl(sharedPreferences);

  final authRepository = AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );

  final loginUsecase = LoginUsecase(authRepository);
  final registerUsecase = RegisterUsecase(authRepository);
  final getMeUsecase = GetMeUsecase(authRepository);

  runApp(MyApp(
    loginUsecase: loginUsecase,
    registerUsecase: registerUsecase,
    getMeUsecase: getMeUsecase,
  ));
}

class MyApp extends StatelessWidget {
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  final GetMeUsecase getMeUsecase;

  const MyApp({
    super.key,
    required this.loginUsecase,
    required this.registerUsecase,
    required this.getMeUsecase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUsecase: loginUsecase,
            registerUsecase: registerUsecase,
            getMeUsecase: getMeUsecase,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ecom App',
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/sign-in': (context) => const SignInPage(),
          '/sign-up': (context) => const SignUpPage(),
        },
      ),
    );
  }
}
