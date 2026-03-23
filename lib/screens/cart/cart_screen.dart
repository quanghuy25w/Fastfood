import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/chip_bar.dart';
import '../checkout/checkout_screen.dart';

/// Giỏ hàng — UI hiện đại, Material Design 3, tối ưu dùng 1 tay.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.onSwitchToHome, this.onSwitchToProfile});

  /// Gọi khi giỏ trống và user bấm "Xem thực đơn".
  final VoidCallback? onSwitchToHome;

  /// Bấm avatar trên header — chuyển sang tab Tài khoản.
  final VoidCallback? onSwitchToProfile;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static final _money = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.orderItems.isEmpty) {
            return Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      AppHeader(
                        subtitle: 'Thêm món ngon vào giỏ',
                        onAvatarTap: widget.onSwitchToProfile,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                Expanded(
                  child: _EmptyCartState(
                    onBrowse: () => widget.onSwitchToHome?.call(),
                  ),
                ),
              ],
            );
          }

          final categories = ['Tất cả', ...cart.orderItems.map((e) => e.product.category).toSet().toList()..sort()];
          final filteredItems = _selectedCategory == null || _selectedCategory == 'Tất cả'
              ? cart.orderItems
              : cart.orderItems.where((e) => e.product.category == _selectedCategory).toList();
          final total = cart.orderItems.fold<double>(
            0,
            (s, e) => s + (e.product.price * e.quantity),
          );

          return Column(
            children: [
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    AppHeader(
                      subtitle: 'Quản lý giỏ hàng của bạn',
                      onAvatarTap: widget.onSwitchToProfile,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AppSearchBar(hint: 'Tìm món trong giỏ'),
                    ),
                    const SizedBox(height: 16),
                    ChipBar(
                      items: categories,
                      selected: _selectedCategory,
                      onSelect: (v) => setState(() => _selectedCategory = v == 'Tất cả' ? null : v),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final line = filteredItems[i];
                    return _CartItemCard(
                      product: line.product,
                      quantity: line.quantity,
                      onIncrease: () => cart.setQuantity(line.product.id, line.quantity + 1),
                      onDecrease: () {
                        if (line.quantity <= 1) {
                          cart.removeLine(line.product.id);
                        } else {
                          cart.setQuantity(line.product.id, line.quantity - 1);
                        }
                      },
                      onRemove: () => _confirmRemove(context, cart, line.product.id, line.product.name),
                      moneyFormat: _money,
                    );
                  },
                ),
              ),
              _CartBottomBar(total: total, itemCount: cart.orderItems.fold<int>(0, (s, e) => s + e.quantity), onCheckout: () async {
                final auth = context.read<AuthProvider>();
                if (auth.user == null) return;
                await Navigator.push<Order?>(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                );
                if (context.mounted) await cart.load(auth.user!.id);
              }),
            ],
          );
        },
      ),
    );
  }

  void _confirmRemove(BuildContext context, CartProvider cart, int productId, String name) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Xóa "$name" khỏi giỏ?', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Huỷ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () {
                        cart.removeLine(productId);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Xóa'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ————— Empty state —————
class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 44,
                color: cs.outline.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Giỏ hàng trống',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm món ngon vào giỏ để bắt đầu đặt hàng',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: onBrowse,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Xem thực đơn'),
            ),
          ],
        ),
      ),
    );
  }
}

// ————— Product card —————
class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.product,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.moneyFormat,
  });

  final Product product;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;
  final NumberFormat moneyFormat;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final unitPrice = product.price;
    final lineTotal = unitPrice * quantity;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 88,
                  height: 88,
                  color: cs.surfaceContainerHighest,
                  child: Icon(Icons.fastfood_outlined, size: 36, color: cs.outline),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 20, color: cs.outline),
                        onPressed: onRemove,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(36, 36),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${moneyFormat.format(unitPrice)} × $quantity',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        moneyFormat.format(lineTotal),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                      ),
                      _QuantityStepper(
                        value: quantity,
                        onDecrease: onDecrease,
                        onIncrease: onIncrease,
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

// ————— Stepper +/- —————
class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int value;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(icon: Icons.remove, onTap: onDecrease),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          _StepperButton(icon: Icons.add, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 40,
          height: 36,
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

// ————— Bottom bar (sticky) —————
class _CartBottomBar extends StatelessWidget {
  const _CartBottomBar({
    required this.total,
    required this.itemCount,
    required this.onCheckout,
  });

  final double total;
  final int itemCount;
  final VoidCallback onCheckout;

  static final _money = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tổng ($itemCount món)',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _money.format(total),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: FilledButton(
                onPressed: onCheckout,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Thanh toán'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
