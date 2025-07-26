import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/auth/domain/i_auth_repository.dart';
import 'package:controlab/app/core/domain/either.dart';
import 'package:controlab/features/auth/domain/auth_failure.dart';
import 'package:controlab/features/auth/domain/user.dart';

// Provider para o repositório. Facilita a troca de implementações.
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return MockAuthRepository();
});

class MockAuthRepository implements IAuthRepository {
  User? _user;

  @override
  Future<Either<AuthFailure, User>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'demo@controlab.com' && password == '123456') {
      _user = User(id: 'user-123', name: 'Dr. Ricardo', email: email);
      // Retorna 'Right' para indicar sucesso.
      return Right(_user!);
    } else {
      // Retorna 'Left' para indicar uma falha.
      return const Left(InvalidCredentials());
    }
  }

  @override
  Future<void> logout() async {
    _user = null;
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<Either<AuthFailure, User>> checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_user != null) {
      return Right(_user!);
    } else {
      return const Left(AuthFailure("Nenhuma sessão ativa."));
    }
  }
}
