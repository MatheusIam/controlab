import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/auth/data/mock_auth_repository.dart';
import 'package:controlab/features/auth/domain/i_auth_repository.dart';
import 'package:controlab/features/auth/domain/user.dart';
// A importação de 'auth_failure.dart' já traz o que é necessário.
import 'package:controlab/features/auth/domain/auth_failure.dart';

// Provider para o AuthNotifier.
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  late IAuthRepository _authRepository;

  @override
  FutureOr<User?> build() {
    _authRepository = ref.watch(authRepositoryProvider);
    return null;
  }

  bool get isAuthenticated => state.value != null;

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await _authRepository.login(email, password);

    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (user) => state = AsyncData(user),
    );
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AsyncData(null);
  }
}
