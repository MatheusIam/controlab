// Modelo simples representando uma localização física de armazenamento de estoque.
// Futuramente podemos expandir com atributos como tipo (geladeira, armário),
// capacidade máxima, temperatura controlada, etc.
class Localizacao {
  final String id;
  final String nome;

  const Localizacao({required this.id, required this.nome});
}
