import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:controlab/features/stock/domain/i_cq_repository.dart';
import 'package:controlab/features/stock/domain/registro_cq.dart';
import 'package:controlab/features/stock/data/cq_repository_impl.dart';

class CQState {
  final AsyncValue<List<RegistroCQ>> registros; // registros do produto focado
  final AsyncValue<void> operacao; // estado de ultima operacao (add)
  const CQState({required this.registros, required this.operacao});
  CQState copyWith({AsyncValue<List<RegistroCQ>>? registros, AsyncValue<void>? operacao}) =>
      CQState(registros: registros ?? this.registros, operacao: operacao ?? this.operacao);
  factory CQState.initial() => const CQState(registros: AsyncValue.loading(), operacao: AsyncValue.data(null));
}

class CQNotifier extends StateNotifier<CQState> {
  final ICQRepository _repo;
  final String produtoId;
  final _uuid = const Uuid();
  CQNotifier(this._repo, this.produtoId) : super(CQState.initial()) {
    carregar();
  }

  Future<void> carregar() async {
    try {
      final regs = await _repo.getRegistrosByProduto(produtoId);
      state = state.copyWith(registros: AsyncValue.data(regs));
    } catch (e, st) {
      state = state.copyWith(registros: AsyncValue.error(e, st));
    }
  }

  Future<void> adicionarRegistro({
    required String lote,
    required String responsavel,
    required StatusLoteCQ status,
    required String observacoes,
    String? anexoPath,
  }) async {
    state = state.copyWith(operacao: const AsyncValue.loading());
    final registro = RegistroCQ(
      id: _uuid.v4(),
      produtoId: produtoId,
      lote: lote,
      data: DateTime.now(),
      responsavel: responsavel,
      status: status,
      observacoes: observacoes,
      anexoPath: anexoPath,
    );
    final previous = state.registros.value ?? [];
    try {
      await _repo.addRegistro(registro);
      final atualizados = [registro, ...previous];
      state = state.copyWith(
        registros: AsyncValue.data(atualizados),
        operacao: const AsyncValue.data(null),
      );
    } catch (e, st) {
      state = state.copyWith(operacao: AsyncValue.error(e, st));
    }
  }
}

final cqNotifierProvider = StateNotifierProvider.family<CQNotifier, CQState, String>((ref, produtoId){
  final repo = ref.watch(cqRepositoryProvider);
  return CQNotifier(repo, produtoId);
});

// Provider derivado: último status CQ do lote do produto
final ultimoStatusCQDoLoteProvider = FutureProvider.family<StatusLoteCQ?, String>((ref, lote) async {
  final repo = ref.watch(cqRepositoryProvider);
  final registro = await repo.getUltimoRegistroDoLote(lote);
  return registro?.status;
});
