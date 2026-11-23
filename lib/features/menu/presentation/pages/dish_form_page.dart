import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/dish_entity.dart';
import '../providers/menu_provider.dart';

class DishFormPage extends StatefulWidget {
  final DishEntity? dish;

  const DishFormPage({super.key, this.dish});

  @override
  State<DishFormPage> createState() => _DishFormPageState();
}

class _DishFormPageState extends State<DishFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _imageCtrl;
  late DishCategory _category;
  late bool _isAvailable;
  bool _saving = false;

  bool get _isEdit => widget.dish != null;

  @override
  void initState() {
    super.initState();
    final d = widget.dish;
    _nameCtrl = TextEditingController(text: d?.name ?? '');
    _descCtrl = TextEditingController(text: d?.description ?? '');
    _priceCtrl = TextEditingController(
      text: d == null ? '' : d.price.toStringAsFixed(0),
    );
    _imageCtrl = TextEditingController(text: d?.imageUrl ?? '');
    _category = d?.category ?? DishCategory.food;
    _isAvailable = d?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final menu = context.read<MenuProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);

    final dish = DishEntity(
      id: widget.dish?.id ?? '',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim().replaceAll(' ', '')),
      imageUrl: _imageCtrl.text.trim(),
      category: _category,
      isAvailable: _isAvailable,
    );

    final error = _isEdit
        ? await menu.updateDish(dish)
        : await menu.addDish(dish);

    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    } else {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Taomni tahrirlash' : 'Yangi taom'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Nomi',
                        prefixIcon: Icon(Icons.restaurant_menu),
                      ),
                      validator: (v) => (v?.trim().isEmpty ?? true)
                          ? 'Taom nomini kiriting'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Tavsif',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Narxi (so\'m)',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      validator: (v) {
                        final value = double.tryParse(
                          (v ?? '').trim().replaceAll(' ', ''),
                        );
                        if (value == null || value <= 0) {
                          return 'To\'g\'ri narx kiriting';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageCtrl,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Rasm havolasi (URL)',
                        prefixIcon: Icon(Icons.image_outlined),
                      ),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isNotEmpty && !value.startsWith('http')) {
                          return 'Havola http bilan boshlanishi kerak';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DishCategory>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Kategoriya',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: [
                        for (final c in DishCategory.values)
                          DropdownMenuItem(value: c, child: Text(c.label)),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _category = v);
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Mavjud (sotuvda)'),
                      value: _isAvailable,
                      onChanged: (v) => setState(() => _isAvailable = v),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isEdit ? 'Saqlash' : 'Qo\'shish'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}