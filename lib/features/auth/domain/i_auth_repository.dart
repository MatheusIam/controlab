import 'dart:async';

import 'package:controlab/app/core/domain/either.dart';
import 'package:controlab/features/auth/domain/auth_failure.dart';
import 'package:controlab/features/auth/domain/user.dart';

abstract class IAuthRepository {
  /// Retorna um stream que emite o usuário atual sempre que o estado de autenticação muda.
  /// Emite `null` se o usuário não estiver logado.
  Stream<User?> getAuthStateChanges();

  /// Obtém o usuário atualmente logado de forma síncrona.
  /// Retorna um [Right] com o [User] se houver uma sessão, ou um [Left] com [AuthFailure].
  Either<AuthFailure, User?> getSignedInUser();

  /// Tenta autenticar um usuário e retorna um [User] em caso de sucesso
  /// ou uma [AuthFailure] em caso de erro.
  Future<Either<AuthFailure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Encerra a sessão do usuário atual.
  /// Retorna um [Right] com `void` em caso de sucesso, ou um [Left] com [AuthFailure].
  Future<Either<AuthFailure, void>> signOut();

  /// Verifica se há uma sessão de usuário ativa.
  @Deprecated('Use getAuthStateChanges() or getSignedInUser() instead')
  Future<Either<AuthFailure, User>> checkAuthStatus();
}
