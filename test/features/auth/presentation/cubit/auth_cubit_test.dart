import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thikrspace_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:thikrspace_beta/features/auth/presentation/cubit/auth_cubit.dart';

// 1. Create a Fake Repository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthCubit authCubit;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    // 2. Stub the auth stream so the Cubit doesn't crash upon creation
    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());

    authCubit = AuthCubit(mockAuthRepository);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit - Day 5 Edge Cases', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError, AuthUnauthenticated] when signUp fails',
      build: () {
        // Force the repository to throw an error
        when(() => mockAuthRepository.signUp('test@test.com', 'password123'))
            .thenThrow(Exception('weak-password'));
        return authCubit;
      },
      act: (cubit) => cubit.signUp('test@test.com', 'password123'),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
        isA<AuthUnauthenticated>(), // Ensures the UI drops back to the input form
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthInitial] when Google Sign-In is cancelled',
      build: () {
        // Returning null simulates the user closing the Google popup
        when(() => mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) async => null);
        return authCubit;
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthInitial>(), // Stops the spinner without throwing a red error box
      ],
    );
  });
}
