import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:controlab/features/auth/domain/i_auth_repository.dart';

// Provider para o repositório. Facilita a troca de implementações.
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return MockAuthRepository();
  // Para usar um backend real:
  // return ApiAuthRepository();
});

class MockAuthRepository implements IAuthRepository {
  @override
  Future<void> login(String email, String password) async {
    // Simula a latência da rede.
    await Future.delayed(const Duration(seconds: 2));
    if (email == 'demo@controlab.com' && password == '123456') {
      // Simula um login bem-sucedido.
      return;
    } else {
      // Simula um erro de autenticação.
      throw Exception('Credenciais inválidas.');
    }
  }
}