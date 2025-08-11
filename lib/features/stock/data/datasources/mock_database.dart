import 'package:controlab/features/stock/domain/localizacao.dart';
import 'package:controlab/features/stock/domain/produto.dart';
import 'package:controlab/features/stock/domain/registro_cq.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Singleton que simula um banco de dados em memória para a aplicação.
/// Mantém o estado dos dados durante a sessão.
class MockDatabase {
  // Instância singleton
  static final MockDatabase instance = MockDatabase._privateConstructor();
  MockDatabase._privateConstructor();

  final Uuid _uuid = const Uuid();

  // Tabelas simuladas
  // Produtos iniciais para testes de alertas e cenários de UI
  // Cada produto foi escolhido para cobrir um caso específico:
  // - prod-exp: vencido (status prioridade alta) sem ser baixo estoque
  // - prod-low: estoque igual ao mínimo (deve acionar alerta de baixo estoque)
  // - prod-high: estoque no limite máximo (alerta de estoque alto na UI)
  // - prod-ok: produto dentro dos limites (nenhum alerta)
  // - prod-dist: produto com estoque distribuído em múltiplas localizações
  final List<Produto> produtos = [
    Produto(
      id: 'prod-exp',
      nome: 'Reagente Hemoglobina',
      quantidadesPorLocal: { 'loc-01': 25 },
      fornecedor: 'BioLab',
      validade: '01/07/2025', // Data passada (considerando hoje > Jul/2025) => vencido
      lote: 'LHEM-2025A',
      categoria: CategoriaProduto.reagentes,
      iconCodePoint: Icons.science_outlined.codePoint,
      estoqueMinimo: 10,
      estoqueMaximo: 100,
    ),
    Produto(
      id: 'prod-low',
      nome: 'Pipetas 10µL',
      quantidadesPorLocal: { 'loc-02': 5 }, // Igual ao mínimo => alerta de baixo estoque
      fornecedor: 'LabTools',
      validade: '31/12/2026',
      lote: 'PIP10-LOTB',
      categoria: CategoriaProduto.consumiveis,
      iconCodePoint: Icons.medication_liquid_outlined.codePoint,
      estoqueMinimo: 5,
      estoqueMaximo: 500,
    ),
    Produto(
      id: 'prod-high',
      nome: 'Tubos Centrifugação 15mL',
      quantidadesPorLocal: { 'loc-02': 100 }, // Igual ao máximo => alerta de estoque alto
      fornecedor: 'PlastiLab',
      validade: '31/12/2027',
      lote: 'TUB15-XL1',
      categoria: CategoriaProduto.consumiveis,
      iconCodePoint: Icons.category_outlined.codePoint,
      estoqueMaximo: 100,
      estoqueMinimo: 10,
    ),
    Produto(
      id: 'prod-ok',
      nome: 'Microscópio Óptico',
      quantidadesPorLocal: { 'loc-03': 2 },
      fornecedor: 'OptiTech',
      validade: '31/12/2030',
      lote: 'MICR-2030',
      categoria: CategoriaProduto.equipamentos,
      iconCodePoint: Icons.precision_manufacturing_outlined.codePoint,
      estoqueMinimo: 1,
      estoqueMaximo: 10,
    ),
    Produto(
      id: 'prod-dist',
      nome: 'Controle de Qualidade Soro Nível 2',
      quantidadesPorLocal: { 'loc-01': 8, 'loc-02': 7 }, // Distribuído
      fornecedor: 'QC Global',
      validade: '30/06/2026',
      lote: 'CQSR-L2-26',
      categoria: CategoriaProduto.reagentes,
      iconCodePoint: Icons.biotech_outlined.codePoint,
      estoqueMinimo: 10,
      estoqueMaximo: 50,
    ),
  ];
  final List<Localizacao> localizacoes = [
    const Localizacao(id: 'loc-01', nome: 'Geladeira A'),
    const Localizacao(id: 'loc-02', nome: 'Almoxarifado Principal'),
    const Localizacao(id: 'loc-03', nome: 'Bancada de Hematologia'),
  ];
  // Registros de Controle de Qualidade (CQ) por produto/lote
  final List<RegistroCQ> registrosCQ = [];

  // Métodos utilitários
  String generateId() => _uuid.v4();
}
