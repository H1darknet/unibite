import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/dish_entity.dart';
import '../providers/menu_provider.dart';
import '../widgets/dish_image.dart';
import 'dish_form_page.dart';

class DishDetailPage extends StatelessWidget {
  final String dishId;

  const DishDetailPage({super.key, required this.dishId});

  @override
  Widget build(BuildContext context) {
    final dish = context.watch<MenuProvider>().findById(dishId);
    final isAdmin =
        context.select<AuthProvider, bool>((p) => p.user?.isAdmin ?? false);
    final theme = Theme.of(context);

    if (dish == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Taom topilmadi')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dish.name),
        actions: [
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Tahrirlash',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DishFormPage(dish: dish)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'O\'chirish',
              onPressed: () => _confirmDelete(context, dish),
            ),
          ],
        ],
      ),
      bottomNavigationBar: isAdmin
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: dish.isAvailable
                      ? () {
                          context.read<CartProvider>().add(dish);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('"${dish.name}" savatchaga qo\'shildi'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(
                    dish.isAvailable ? 'Savatchaga qo\'shish' : 'Tugagan',
                  ),
                ),
              ),
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: DishImage(url: dish.imageUrl),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          formatPrice(dish.price),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Chip(label: Text(dish.category.label)),
                      ],
                    ),
                    if (!dish.isAvailable) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Hozircha tugagan',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      dish.description.isEmpty
                          ? 'Tavsif kiritilmagan.'
                          : dish.description,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, DishEntity dish) async {
    final menu = context.read<MenuProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Taomni o\'chirish'),
        content: Text('"${dish.name}" menyudan o\'chiriladi. Davom etasizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final error = await menu.deleteDish(dish.id);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    navigator.pop();
  }
}