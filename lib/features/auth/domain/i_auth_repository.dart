abstract class IAuthRepository {
  Future<void> login(String email, String password);
}