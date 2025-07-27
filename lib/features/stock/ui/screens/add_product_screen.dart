import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:controlab/features/stock/application/stock_notifier.dart';
import 'package:controlab/features/stock/domain/produto.dart';

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
  
  CategoriaProduto _selectedCategoria = CategoriaProduto.consumiveis;
  IconData _selectedIcon = CategoriaProduto.consumiveis.icon;
  bool get _isEditing => widget.produto != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.produto?.nome ?? '');
    _quantityController = TextEditingController(text: widget.produto?.quantidade.toString() ?? '');
    _supplierController = TextEditingController(text: widget.produto?.fornecedor ?? '');
    _lotController = TextEditingController(text: widget.produto?.lote ?? '');
    _expiryDateController = TextEditingController(text: widget.produto?.validade ?? '');
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
      final notifier = ref.read(stockNotifierProvider.notifier);
      if (_isEditing) {
        final updatedProduct = widget.produto!.copyWith(
          nome: _nameController.text,
          quantidade: int.parse(_quantityController.text),
          fornecedor: _supplierController.text,
          lote: _lotController.text,
          validade: _expiryDateController.text,
          categoria: _selectedCategoria,
          iconCodePoint: _selectedIcon.codePoint,
        );
        notifier.updateProduct(updatedProduct);
      } else {
        final newProduct = Produto(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nome: _nameController.text,
          quantidade: int.parse(_quantityController.text),
          fornecedor: _supplierController.text,
          validade: _expiryDateController.text,
          lote: _lotController.text,
          status: StatusProduto.emEstoque,
          categoria: _selectedCategoria,
          iconCodePoint: _selectedIcon.codePoint,
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
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido.';
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
              FilledButton(
                onPressed: _submitForm,
                child: Text(_isEditing ? 'Salvar Alterações' : 'Adicionar Produto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
