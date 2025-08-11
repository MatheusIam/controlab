import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:controlab/features/stock/application/stock_notifier.dart';
import 'package:controlab/features/stock/domain/produto.dart';
import 'package:controlab/features/stock/domain/localizacao.dart';
import 'package:controlab/features/stock/application/localizacao_providers.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final Produto? produto; // Produto existente para edição (pode ser nulo)
  const AddProductScreen({super.key, this.produto});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _supplierController;
  late final TextEditingController _lotController;
  late final TextEditingController _expiryDateController;
  late final TextEditingController _minStockController;
  late final TextEditingController _maxStockController;
  
  CategoriaProduto _selectedCategoria = CategoriaProduto.consumiveis;
  IconData _selectedIcon = CategoriaProduto.consumiveis.icon;
  Localizacao? _selectedLocation; // localização inicial selecionada (somente criação)
  bool get _isEditing => widget.produto != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.produto?.nome ?? '');
  // Em edição usamos quantidadeTotal explícita.
  _quantityController = TextEditingController(text: widget.produto?.quantidadeTotal.toString() ?? '');
    _supplierController = TextEditingController(text: widget.produto?.fornecedor ?? '');
    _lotController = TextEditingController(text: widget.produto?.lote ?? '');
    _expiryDateController = TextEditingController(text: widget.produto?.validade ?? '');
  _minStockController = TextEditingController(text: widget.produto?.estoqueMinimo?.toString() ?? '');
  _maxStockController = TextEditingController(text: widget.produto?.estoqueMaximo?.toString() ?? '');
    if (_isEditing) {
      _selectedCategoria = widget.produto!.categoria;
      _selectedIcon = widget.produto!.icone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _supplierController.dispose();
    _lotController.dispose();
    _expiryDateController.dispose();
  _minStockController.dispose();
  _maxStockController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _expiryDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (!_isEditing && _selectedLocation == null) {
        // Segurança extra caso usuário clique antes de carregar/selecionar localização
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione a Localização Inicial antes de continuar.')),
        );
        return;
      }
      final notifier = ref.read(stockNotifierProvider.notifier);
      if (_isEditing) {
        final updatedProduct = widget.produto!.copyWith(
          nome: _nameController.text,
          // TODO: futura edição granular por local; por enquanto redistribui tudo na localização default (se existir única)
          quantidadesPorLocal: () {
            final novoTotal = int.parse(_quantityController.text);
            if (widget.produto!.quantidadesPorLocal.length == 1) {
              final k = widget.produto!.quantidadesPorLocal.keys.first;
              return {k: novoTotal};
            }
            return {Produto.defaultLocationId: novoTotal};
          }(),
          fornecedor: _supplierController.text,
          lote: _lotController.text,
          validade: _expiryDateController.text,
          categoria: _selectedCategoria,
          iconCodePoint: _selectedIcon.codePoint,
          estoqueMinimo: int.tryParse(_minStockController.text),
          estoqueMaximo: int.tryParse(_maxStockController.text),
        );
        notifier.updateProduct(updatedProduct);
      } else {
        final quantidadeInicial = int.parse(_quantityController.text);
        final newProduct = Produto(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nome: _nameController.text,
          quantidadesPorLocal: { _selectedLocation!.id : quantidadeInicial },
          fornecedor: _supplierController.text,
          validade: _expiryDateController.text,
          lote: _lotController.text,
          categoria: _selectedCategoria,
          iconCodePoint: _selectedIcon.codePoint,
          estoqueMinimo: int.tryParse(_minStockController.text),
          estoqueMaximo: int.tryParse(_maxStockController.text),
        );
        notifier.addProduct(newProduct);
      }
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Produto' : 'Adicionar Produto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Produto'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              // Seleção de Localização inicial apenas no fluxo de criação
              if (!_isEditing) ...[
                Consumer(
                  builder: (context, ref, _) {
                    final locationsAsync = ref.watch(locationsListProvider);
                    return locationsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: LinearProgressIndicator(),
                      ),
                      error: (err, stack) => Text('Erro ao carregar localizações: $err'),
                      data: (locations) {
                        if (_selectedLocation != null && !locations.any((l) => l.id == _selectedLocation!.id)) {
                          _selectedLocation = null; // localização removida
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DropdownButtonFormField<Localizacao>(
                              value: _selectedLocation,
                              decoration: const InputDecoration(labelText: 'Localização Inicial'),
                              hint: const Text('Selecione um local'),
                              items: locations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc.nome))).toList(),
                              onChanged: (value) {
                                setState(() { _selectedLocation = value; });
                              },
                              validator: (value) => value == null ? 'Campo obrigatório' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(labelText: 'Quantidade nesse Local'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Campo obrigatório';
                                final parsed = int.tryParse(value);
                                if (parsed == null || parsed <= 0) return 'Insira um número válido (>0).';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    );
                  },
                ),
              ] else ...[
                // Fluxo de edição mantém campo de quantidade total legado (até refatoração futura)
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantidade (Total)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Campo obrigatório';
                    if (int.tryParse(value) == null) return 'Por favor, insira um número válido.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _minStockController,
                decoration: const InputDecoration(labelText: 'Estoque Mínimo (Opcional)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                    return 'Insira um número válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxStockController,
                decoration: const InputDecoration(labelText: 'Estoque Máximo (Opcional)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                    return 'Insira um número válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _supplierController,
                decoration: const InputDecoration(labelText: 'Fornecedor'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lotController,
                decoration: const InputDecoration(labelText: 'Lote'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expiryDateController,
                decoration: InputDecoration(
                  labelText: 'Data de Validade',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ),
                readOnly: true,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CategoriaProduto>(
                value: _selectedCategoria,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: CategoriaProduto.values.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Row(
                      children: [
                        Icon(categoria.icon, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 10),
                        Text(categoria.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategoria = value;
                      _selectedIcon = value.icon;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              Consumer(
                builder: (context, ref, _) {
                  final locationsAsync = ref.watch(locationsListProvider);
                  final isCreating = !_isEditing;
                  final locationReady = !isCreating || (locationsAsync is AsyncData && _selectedLocation != null);
                  return FilledButton(
                    onPressed: locationReady ? _submitForm : null,
                    child: Text(_isEditing ? 'Salvar Alterações' : 'Adicionar Produto'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
