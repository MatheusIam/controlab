import 'dart:async';

import 'package:controlab/features/auth/data/mock_auth_repository.dart';
import 'package:controlab/features/auth/domain/i_auth_repository.dart';
import 'package:controlab/features/auth/domain/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier para gerenciar o estado de autenticação do usuário.
class AuthNotifier extends AsyncNotifier<User?> {
  late final IAuthRepository _repository;

  @override
  FutureOr<User?> build() {
    _repository = ref.watch(authRepositoryProvider);

    // Ouve o stream de estado de autenticação do repositório.
    final subscription = _repository.getAuthStateChanges().listen(
      (user) => state = AsyncValue.data(user),
      onError: (error) => state = AsyncValue.error(error, StackTrace.current),
    );

    ref.onDispose(() => subscription.cancel());

    // Retorna o usuário logado no momento da inicialização, se houver.
    return _repository.getSignedInUser().fold((l) => null, (r) => r);
  }

  /// Tenta autenticar o usuário com e-mail e senha.
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    final failureOrSuccess = await _repository.signInWithEmailAndPassword(
      email,
      password,
    );
    // O estado é atualizado pelo stream, mas podemos setar o erro aqui.
    state = failureOrSuccess.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  /// Desconecta o usuário atual.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final failureOrSuccess = await _repository.signOut();
    // O estado é atualizado para nulo pelo stream, mas podemos setar o erro.
    state = failureOrSuccess.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }
}

/// Provider para o AuthNotifier.
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

/// **NOVO**: Fornece um stream direto das mudanças de estado de autenticação.
/// Este provider é a fonte de verdade para o GoRouter reagir a login/logout.
final authStateChangesProvider = StreamProvider.autoDispose<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.getAuthStateChanges();
});

final currentUserRoleProvider = Provider<UserRole?>((ref) {
  final user = ref.watch(authNotifierProvider).value;
  return user?.role;
});
