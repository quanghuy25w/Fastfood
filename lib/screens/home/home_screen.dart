import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════════════════════

const _kOuterPadding = 16.0;
const _kSectionSpacing = 12.0;
const _kInnerSpacing = 8.0;
const _kBorderRadius = 18.0;
const _kGridSpacing = 12.0;

/// Màn Thực đơn — thiết kế ShopeeFood/GrabFood, premium, clean.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onSwitchToCart, this.onSwitchToProfile});

  /// Gọi khi user bấm nút giỏ hàng (floating) — chuyển sang tab Cart.
  final VoidCallback? onSwitchToCart;

  /// Gọi khi user bấm avatar — chuyển sang tab Tài khoản.
  final VoidCallback? onSwitchToProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _future;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getProducts();
  }

  static final _money = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  List<Product> _filterByCategory(List<Product> list) {
    if (_selectedCategory == null || _selectedCategory!.isEmpty) return list;
    return list.where((p) => p.category == _selectedCategory).toList();
  }

  List<String> _categoriesFromProducts(List<Product> list) {
    final cats = <String>{};
    for (final p in list) {
      if (p.category.trim().isNotEmpty) cats.add(p.category);
    }
    return ['Tất cả', ...cats.toList()..sort()];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: cs.primary,
          onRefresh: () async {
            final next = ApiService.instance.getProducts();
            setState(() {
              _future = next;
            });
            await next;
          },
          child: FutureBuilder<List<Product>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(color: cs.primary),
                );
              }
              if (snap.hasError || !snap.hasData) {
                return Center(
                  child: Text(
                    'Lỗi tải: ${snap.error}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }
              final list = snap.data!;
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'Chưa có món',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              final categories = _categoriesFromProducts(list);
              final filtered = _filterByCategory(list);

              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: HeaderWidget(
                      onAvatarTap: widget.onSwitchToProfile ?? () {},
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: _kSectionSpacing),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: _kOuterPadding),
                      child: SearchBarWidget(),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: _kSectionSpacing),
                  ),
                  SliverToBoxAdapter(
                    child: CategoryListWidget(
                      categories: categories,
                      selected: _selectedCategory,
                      onSelect: (c) {
                        setState(
                          () => _selectedCategory = c == 'Tất cả' ? null : c,
                        );
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: _kSectionSpacing),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _kOuterPadding,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: _kGridSpacing,
                            crossAxisSpacing: _kGridSpacing,
                            childAspectRatio: 0.68,
                          ),
                      delegate: SliverChildBuilderDelegate((context, i) {
                        final p = filtered[i];
                        return ProductCardWidget(
                          product: p,
                          priceLabel: _money.format(p.price),
                          onAdd: () async {
                            await context.read<CartProvider>().addProduct(p);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã thêm ${p.name}')),
                              );
                            }
                          },
                        );
                      }, childCount: filtered.length),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingCartButton(
        count: context.watch<CartProvider>().totalCount,
        onTap: widget.onSwitchToCart ?? () {},
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HEADER WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key, required this.onAvatarTap});

  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final name = user?.name ?? 'Bạn';
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _kOuterPadding,
        _kInnerSpacing,
        _kOuterPadding,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    letterSpacing: -0.3,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: cs.primary.withOpacity(0.12),
              child: Text(
                (name.isNotEmpty) ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SEARCH BAR WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(_kBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        readOnly: true,
        onTap: () {},
        decoration: InputDecoration(
          hintText: 'Tìm món ăn...',
          hintStyle: TextStyle(
            color: cs.onSurfaceVariant.withOpacity(0.9),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 24,
            color: cs.onSurfaceVariant.withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CATEGORY LIST WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

class CategoryListWidget extends StatelessWidget {
  const CategoryListWidget({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  final List<String> categories;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: _kOuterPadding),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final c = categories[i];
          final isAll = c == 'Tất cả';
          final isSelected =
              (isAll && selected == null) || (!isAll && selected == c);

          return GestureDetector(
            onTap: () => onSelect(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary.withOpacity(0.15) : cs.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  c,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRODUCT CARD WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

class ProductCardWidget extends StatelessWidget {
  const ProductCardWidget({
    super.key,
    required this.product,
    required this.priceLabel,
    required this.onAdd,
  });

  final Product product;
  final String priceLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(_kBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(_kBorderRadius),
              ),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: cs.surfaceContainerHighest.withOpacity(0.5),
                  child: Icon(
                    Icons.fastfood_outlined,
                    size: 40,
                    color: cs.outline,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(_kInnerSpacing + 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                    fontSize: 14,
                    height: 1.3,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: _kInnerSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      priceLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onAdd,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            size: 22,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FLOATING CART BUTTON
// ═══════════════════════════════════════════════════════════════════════════════

class FloatingCartButton extends StatelessWidget {
  const FloatingCartButton({
    super.key,
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        right: _kOuterPadding,
        bottom: MediaQuery.of(context).padding.bottom + 88,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(Icons.shopping_bag_rounded, color: cs.onPrimary, size: 26),
                if (count > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
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
