import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/auth/data/mock_auth_repository.dart';
import 'package:controlab/features/auth/domain/i_auth_repository.dart';

// Provider para o AuthNotifier. autoDispose garante que o estado seja resetado
// quando o widget que o consome é removido da árvore.
final authNotifierProvider =
    AsyncNotifierProvider.autoDispose<AuthNotifier, void>(AuthNotifier.new);

class AuthNotifier extends AutoDisposeAsyncNotifier<void> {
  late IAuthRepository _authRepository;

  @override
  FutureOr<void> build() {
    // No método build, inicializamos dependências.
    _authRepository = ref.watch(authRepositoryProvider);
  }

  Future<void> login(String email, String password) async {
    // Define o estado como 'loading'
    state = const AsyncLoading();
    // Atualiza o estado com o resultado da operação assíncrona.
    state = await AsyncValue.guard(
      () => _authRepository.login(email, password),
    );
  }
}