import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/dish_entity.dart';
import '../providers/menu_provider.dart';
import '../widgets/dish_card.dart';
import 'dish_detail_page.dart';
import 'dish_form_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  void initState() {
    super.initState();
    context.read<MenuProvider>().startListening();
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final isAdmin =
        context.select<AuthProvider, bool>((p) => p.user?.isAdmin ?? false);
    final cartCount = context.select<CartProvider, int>((c) => c.totalCount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UniBite'),
        actions: [
          if (!isAdmin)
            IconButton(
              tooltip: 'Savatcha',
              icon: Badge(
                label: Text('$cartCount'),
                isLabelVisible: cartCount > 0,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartPage()),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Chiqish',
            onPressed: () {
              context.read<CartProvider>().clear();
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DishFormPage()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Taom qo\'shish'),
            )
          : null,
      body: Column(
        children: [
          _CategoryChips(
            selected: menu.selectedCategory,
            onSelected: menu.selectCategory,
          ),
          Expanded(child: _buildBody(context, menu, isAdmin)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, MenuProvider menu, bool isAdmin) {
    if (menu.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (menu.error != null) {
      return Center(child: Text(menu.error!));
    }
    final dishes = menu.dishes;
    if (dishes.isEmpty) {
      return Center(
        child: Text(
          isAdmin
              ? 'Menyu bo\'sh. Pastdagi tugma bilan taom qo\'shing.'
              : 'Menyu hozircha bo\'sh.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        final dish = dishes[index];
        return DishCard(
          dish: dish,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DishDetailPage(dishId: dish.id),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final DishCategory? selected;
  final ValueChanged<DishCategory?> onSelected;

  const _CategoryChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Hammasi'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final category in DishCategory.values)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(category.label),
                selected: selected == category,
                onSelected: (_) => onSelected(category),
              ),
            ),
        ],
      ),
    );
  }
}