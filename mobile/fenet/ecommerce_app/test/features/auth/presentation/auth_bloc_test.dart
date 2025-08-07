import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/error/failure.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/get_me.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/login.dart';
import 'package:ecommerce_app/features/auth/domain/usecases/register.dart';
import 'package:ecommerce_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:ecommerce_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockGetMeUsecase extends Mock implements GetMeUsecase {}

void main() {
  late AuthBloc bloc;
  late MockLoginUsecase mockLogin;
  late MockRegisterUsecase mockRegister;
  late MockGetMeUsecase mockGetMe;

  const tEmail = 'user@gmail.com';
  const tPassword = 'userpassword';
  const tName = 'Mr. User';
  const tToken = 'dummy_token';

  const tUser = User(id: '1', name: tName, email: tEmail, password: tPassword);

  setUp(() {
    mockLogin = MockLoginUsecase();
    mockRegister = MockRegisterUsecase();
    mockGetMe = MockGetMeUsecase();
    bloc = AuthBloc(
      loginUsecase: mockLogin,
      registerUsecase: mockRegister,
      getMeUsecase: mockGetMe,
    );

    registerFallbackValue(const LoginEvent(email: tEmail, password: tPassword));
    registerFallbackValue(const RegisterEvent(name: tName, email: tEmail, password: tPassword));
    registerFallbackValue(const GetMeEvent(tToken));
  });

  group('LoginEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthTokenSaved] when login is successful',
      build: () {
        when(() => mockLogin(email: tEmail, password: tPassword))
            .thenAnswer((_) async => const Right('token'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoginEvent(email: tEmail, password: tPassword)),
      expect: () => [AuthLoading(), AuthTokenSaved()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when login fails',
      build: () {
        when(() => mockLogin(email: tEmail, password: tPassword))
            .thenAnswer((_) async => Left(ServerFailure(message: 'Login failed')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoginEvent(email: tEmail, password: tPassword)),
      expect: () => [AuthLoading(), const AuthFailure('Login failed')],
    );
  });

  group('RegisterEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when register is successful',
      build: () {
        when(() => mockRegister(name: tName, email: tEmail, password: tPassword))
            .thenAnswer((_) async => Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const RegisterEvent(name: tName, email: tEmail, password: tPassword)),
      expect: () => [AuthLoading(), AuthSuccess(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when register fails',
      build: () {
        when(() => mockRegister(name: tName, email: tEmail, password: tPassword))
            .thenAnswer((_) async => Left(ServerFailure(message: 'Register failed')));
        return bloc;
      },
      act: (bloc) => bloc.add(const RegisterEvent(name: tName, email: tEmail, password: tPassword)),
      expect: () => [AuthLoading(), const AuthFailure('Register failed')],
    );
  });

  group('GetMeEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when getMe is successful',
      build: () {
        when(() => mockGetMe(token: tToken)).thenAnswer((_) async => Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetMeEvent(tToken)),
      expect: () => [AuthLoading(), AuthSuccess(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when getMe fails',
      build: () {
        when(() => mockGetMe(token: tToken))
            .thenAnswer((_) async => Left(ServerFailure(message: 'Unauthorized')));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetMeEvent(tToken)),
      expect: () => [AuthLoading(), const AuthFailure('Unauthorized')],
    );
  });
}
