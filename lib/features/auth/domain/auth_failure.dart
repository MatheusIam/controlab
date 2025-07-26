import 'package:controlab/app/core/domain/failures.dart';

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class InvalidCredentials extends AuthFailure {
  const InvalidCredentials() : super('Email ou senha inválidos.');
}

class ServerError extends AuthFailure {
  const ServerError() : super('Ocorreu um erro no servidor. Tente novamente.');
}
