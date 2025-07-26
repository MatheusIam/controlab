import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/auth/domain/i_auth_repository.dart';
import 'package:controlab/app/core/domain/either.dart';
import 'package:controlab/features/auth/domain/auth_failure.dart';
import 'package:controlab/features/auth/domain/user.dart';

// Provider para o repositório. Facilita a troca de implementações.
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  // Retorna a instância singleton para manter o estado do usuário.
  return MockAuthRepository.instance;
});

class MockAuthRepository implements IAuthRepository {
  // Implementação Singleton para manter o estado do usuário mockado durante a sessão.
  MockAuthRepository._privateConstructor();
  static final MockAuthRepository instance =
      MockAuthRepository._privateConstructor();

  User? _user;
  final _authStateController = StreamController<User?>.broadcast();

  @override
  Stream<User?> getAuthStateChanges() {
    return _authStateController.stream;
  }

  @override
  Either<AuthFailure, User?> getSignedInUser() {
    if (_user != null) {
      return Right(_user);
    } else {
      return const Left(AuthFailure("Nenhuma sessão ativa."));
    }
  }

  @override
  Future<Either<AuthFailure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'demo@controlab.com' && password == '123456') {
      _user = User(id: 'user-123', name: 'Dr. Ricardo', email: email);
      _authStateController.add(_user);
      return Right(_user!);
    } else {
      return const Left(InvalidCredentials());
    }
  }

  @override
  Future<Either<AuthFailure, void>> signOut() async {
    _user = null;
    _authStateController.add(null);
    await Future.delayed(const Duration(milliseconds: 200));
    return const Right(null); // Retorna Right(null) para representar void
  }

  @override
  @Deprecated('Use getAuthStateChanges() or getSignedInUser() instead')
  Future<Either<AuthFailure, User>> checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_user != null) {
      return Right(_user!);
    } else {
      return const Left(AuthFailure("Nenhuma sessão ativa."));
    }
  }
}
