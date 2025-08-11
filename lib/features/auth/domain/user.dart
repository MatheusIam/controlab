enum UserRole { administrador, gestorDeQualidade, operadorDeEstoque }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  User({required this.id, required this.name, required this.email, required this.role});

  User copyWith({String? name, String? email, UserRole? role}) => User(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
      );
}
