import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/product_item.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();

    // Load products after first frame to ensure Provider is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load product list from database via Provider.
  Future<void> _loadProducts() async {
    await context.read<ProductProvider>().loadProducts();
  }

  /// Open add screen, then refresh list after returning.
  Future<void> _openAddProductScreen() async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddProductScreen()));

    if (result == true && mounted) {
      await _loadProducts();
    }
  }

  /// Open detail screen and refresh list when data changed.
  Future<void> _openProductDetailScreen(Product product) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );

    if (result == true && mounted) {
      await _loadProducts();
    }
  }

  Future<void> _addToCart(Product product) async {
    if (product.id == null) {
      AppHelpers.showErrorSnackBar(context, 'Khong the them san pham nay vao gio');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();
    final userId = authProvider.currentUser?.id ?? cartProvider.activeUserId;

    if (userId == null) {
      AppHelpers.showWarningSnackBar(context, 'Vui long dang nhap de dat hang');
      return;
    }

    await cartProvider.addItem(
      CartItem(
        userId: userId,
        productId: product.id!,
        name: product.name,
        price: product.price,
        quantity: 1,
        image: product.image,
      ),
    );

    if (!mounted) {
      return;
    }

    if (cartProvider.errorMessage != null) {
      AppHelpers.showErrorSnackBar(context, cartProvider.errorMessage!);
      return;
    }

    AppHelpers.showSuccessSnackBar(context, 'Da them vao gio');
  }

  List<Product> _applyLocalFilters(List<Product> source) {
    final query = _searchController.text.trim().toLowerCase();

    return source.where((product) {
      final matchCategory =
          _selectedCategoryId == null || product.categoryId == _selectedCategoryId;

      final matchQuery =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          '${product.categoryId ?? ''}'.contains(query);

      return matchCategory && matchQuery;
    }).toList();
  }

  List<int> _extractCategories(List<Product> products) {
    final set = <int>{};
    for (final product in products) {
      if (product.categoryId != null) {
        set.add(product.categoryId!);
      }
    }

    final items = set.toList()..sort();
    return items;
  }

  String _categoryLabel(int id) {
    switch (id) {
      case 1:
        return 'Burger';
      case 2:
        return 'Pizza';
      case 3:
        return 'Ga ran';
      case 4:
        return 'Do uong';
      default:
        return 'Loai $id';
    }
  }

  IconData _categoryIcon(int id) {
    switch (id) {
      case 1:
        return Icons.lunch_dining_outlined;
      case 2:
        return Icons.local_pizza_outlined;
      case 3:
        return Icons.egg_outlined;
      case 4:
        return Icons.local_drink_outlined;
      default:
        return Icons.fastfood_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final productProvider = context.watch<ProductProvider>();
    final filteredProducts = _applyLocalFilters(productProvider.products);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FastFood Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Them san pham',
            onPressed: _openAddProductScreen,
          ),
        ],
      ),
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 10 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Column(
          children: [
            _HeroBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Tim burger, pizza, nuoc uong...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    selected: _selectedCategoryId == null,
                    label: 'Tat ca',
                    icon: Icons.grid_view_rounded,
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = null;
                      });
                    },
                  ),
                  ..._extractCategories(productProvider.products).map((id) {
                    return _CategoryChip(
                      selected: _selectedCategoryId == id,
                      label: _categoryLabel(id),
                      icon: _categoryIcon(id),
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = id;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildBody(
                colors: colors,
                isLoading: productProvider.isLoading,
                products: filteredProducts,
                errorMessage: productProvider.errorMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({
    required AppColorPalette colors,
    required bool isLoading,
    required List<Product> products,
    required String? errorMessage,
  }) {
    if (isLoading && products.isEmpty) {
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.zero,
            child: LoadingWidget.small(
              message: null,
              indicatorColor: colors.primary,
            ),
          );
        },
      );
    }

    if (errorMessage != null && products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: colors.error, size: 34),
              const SizedBox(height: 10),
              Text(errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              CustomButton.secondary(
                text: 'Thu lai',
                onPressed: _loadProducts,
                leadingIcon: const Icon(Icons.refresh),
                width: 170,
              ),
            ],
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.no_food_outlined, size: 44, color: colors.textSecondary),
              const SizedBox(height: 10),
              Text(
                'Khong tim thay mon phu hop',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              const Text('Thu doi tu khoa hoac chon danh muc khac'),
            ],
          ),
        ),
      );
    }

    final grid = RefreshIndicator(
      onRefresh: _loadProducts,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 1100
              ? 4
              : constraints.maxWidth >= 760
              ? 3
              : 2;

          final cardWidth =
              (constraints.maxWidth - (16 * 2) - ((crossAxisCount - 1) * 12)) /
              crossAxisCount;
          final cardHeight = math.max(220, cardWidth * 1.34);
          final ratio = cardWidth / cardHeight;

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: ratio,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductItem(
                product: product,
                onTap: () {
                  _openProductDetailScreen(product);
                },
                onAdd: () {
                  _addToCart(product);
                },
              );
            },
          );
        },
      ),
    );

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Dang tai menu...',
      child: grid,
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [colors.primary, colors.primary.withValues(alpha: 0.86)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dat mon sieu toc',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mon nong, gia ro rang, thanh toan nhanh gon',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onPrimary.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 24,
              backgroundColor: colors.secondary,
              child: Icon(Icons.fastfood_rounded, color: colors.onSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? colors.primary : colors.surface,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? colors.primary : colors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? colors.onPrimary : colors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? colors.onPrimary : colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
