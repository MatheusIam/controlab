import 'dart:async';

import 'package:controlab/app/core/domain/either.dart';
import 'package:controlab/features/auth/data/mock_auth_repository.dart';
import 'package:controlab/features/auth/domain/i_auth_repository.dart';
import 'package:controlab/features/auth/domain/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// CORREÇÃO: A importação não utilizada de 'auth_failure.dart' foi removida.

/// Notifier para gerenciar o estado de autenticação do usuário.
///
/// Este AsyncNotifier lida com o login, logout e observa o estado
/// de autenticação do usuário em tempo real.
class AuthNotifier extends AsyncNotifier<User?> {
  late final IAuthRepository _repository;

  @override
  FutureOr<User?> build() {
    _repository = ref.watch(authRepositoryProvider);

    // Ouve o stream de estado de autenticação do repositório.
    // Quando um novo estado é emitido, o estado do notifier é atualizado.
    final subscription = _repository.getAuthStateChanges().listen(
      (user) => state = AsyncValue.data(user),
    );

    // Garante que o subscription seja cancelado quando o notifier for descartado.
    ref.onDispose(() => subscription.cancel());

    // Retorna o usuário atualmente logado, se houver.
    return _repository.getSignedInUser().fold((l) => null, (r) => r);
  }

  /// Tenta autenticar o usuário com e-mail e senha.
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    // Define o estado como carregando.
    state = const AsyncValue.loading();
    // Chama o método de login do repositório.
    final failureOrSuccess = await _repository.signInWithEmailAndPassword(
      email,
      password,
    );
    // Atualiza o estado com base no resultado (sucesso ou erro).
    state = failureOrSuccess.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  /// Desconecta o usuário atual.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final failureOrSuccess = await _repository.signOut();
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
