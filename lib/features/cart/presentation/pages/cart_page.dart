import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/formatters.dart';
import '../../../menu/presentation/widgets/dish_image.dart';
import '../providers/cart_provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Savatcha')),
      body: cart.isEmpty
          ? const Center(child: Text('Savatcha bo\'sh'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: DishImage(url: item.dish.imageUrl),
                          ),
                        ),
                        title: Text(item.dish.name),
                        subtitle: Text(formatPrice(item.total)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => context
                                  .read<CartProvider>()
                                  .decrease(item.dish.id),
                            ),
                            Text(
                              '${item.quantity}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => context
                                  .read<CartProvider>()
                                  .increase(item.dish.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                _Summary(cart: cart),
              ],
            ),
    );
  }
}

class _Summary extends StatelessWidget {
  final CartProvider cart;

  const _Summary({required this.cart});

  Future<void> _pickTime(BuildContext context) async {
    final provider = context.read<CartProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        provider.pickupTime ?? DateTime.now().add(const Duration(minutes: 30)),
      ),
      helpText: 'Olish vaqtini tanlang',
    );
    if (picked == null) return;

    final now = DateTime.now();
    final time =
        DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    if (time.isBefore(now.add(const Duration(minutes: 10)))) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Olish vaqti hozirdan kamida 10 daqiqa keyin bo\'lsin'),
        ),
      );
      return;
    }
    provider.setPickupTime(time);
  }

  void _checkout(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    if (cart.pickupTime == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Avval olish vaqtini tanlang')),
      );
      return;
    }
    // Buyurtma berish Orders bosqichida shu yerga ulanadi.
    messenger.showSnackBar(
      const SnackBar(content: Text('Buyurtma berish keyingi bosqichda ulanadi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pickup = cart.pickupTime;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: const Text('Olish vaqti'),
              subtitle: Text(
                pickup == null
                    ? 'Tanlanmagan'
                    : TimeOfDay.fromDateTime(pickup).format(context),
              ),
              trailing: TextButton(
                onPressed: () => _pickTime(context),
                child: Text(pickup == null ? 'Tanlash' : 'O\'zgartirish'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jami (${cart.totalCount} ta)',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  formatPrice(cart.totalPrice),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _checkout(context),
              child: const Text('Buyurtma berish'),
            ),
          ],
        ),
      ),
    );
  }
}