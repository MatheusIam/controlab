import 'package:controlab/app/core/domain/either.dart';
import 'package:controlab/features/auth/domain/auth_failure.dart';
import 'package:controlab/features/auth/domain/user.dart';

abstract class IAuthRepository {
  /// Tenta autenticar um usuário e retorna um [User] em caso de sucesso
  /// ou uma [AuthFailure] em caso de erro.
  Future<Either<AuthFailure, User>> login(String email, String password);

  /// Encerra a sessão do usuário atual.
  Future<void> logout();

  /// Verifica se há uma sessão de usuário ativa.
  Future<Either<AuthFailure, User>> checkAuthStatus();
}
