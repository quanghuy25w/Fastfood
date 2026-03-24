import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/chip_bar.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.onSwitchToHome, this.onSwitchToProfile});

  final VoidCallback? onSwitchToHome;
  final VoidCallback? onSwitchToProfile;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static final _money = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      // ĐỔI: Sử dụng surface thay vì màu fix cứng
      backgroundColor: cs.surface, 

      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          /// ===== EMPTY =====
          if (cart.orderItems.isEmpty) {
            return Column(
              children: [
                SafeArea(
                  child: AppHeader(
                    subtitle: 'Giỏ hàng',
                    onAvatarTap: widget.onSwitchToProfile,
                  ),
                ),
                Expanded(child: _EmptyCart(onBrowse: widget.onSwitchToHome)),
              ],
            );
          }

          /// ===== DATA (LOGIC GIỮ NGUYÊN) =====
          final categories = [
            'Tất cả',
            ...cart.orderItems.map((e) => e.product.category).toSet(),
          ];
          final filtered =
              _selectedCategory == null || _selectedCategory == 'Tất cả'
              ? cart.orderItems
              : cart.orderItems
                    .where((e) => e.product.category == _selectedCategory)
                    .toList();

          final total = cart.orderItems.fold<double>(
            0,
            (s, e) => s + (e.product.price * e.quantity),
          );

          return Stack( // Sử dụng Stack để BottomBar đè lên List chuẩn hơn
            children: [
              Column(
                children: [
                  /// HEADER
                  SafeArea(
                    bottom: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppHeader(
                          subtitle: 'Giỏ hàng',
                          onAvatarTap: widget.onSwitchToProfile,
                        ),
                        const SizedBox(height: 4),
                        ChipBar(
                          items: categories,
                          selected: _selectedCategory,
                          onSelect: (v) => setState(
                            () => _selectedCategory = v == 'Tất cả' ? null : v,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  /// LIST
                  Expanded(
                    child: ListView.separated(
                      // Padding bottom cao để không bị BottomBar che
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final line = filtered[i];
                        return _CartItem(
                          product: line.product,
                          quantity: line.quantity,
                          onIncrease: () =>
                              cart.setQuantity(line.product.id, line.quantity + 1),
                          onDecrease: () {
                            if (line.quantity <= 1) {
                              cart.removeLine(line.product.id);
                            } else {
                              cart.setQuantity(line.product.id, line.quantity - 1);
                            }
                          },
                          onRemove: () {
                            cart.removeLine(line.product.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Đã xóa sản phẩm'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: cs.errorContainer,
                            
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              /// BOTTOM BAR
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _BottomBar(
                  total: total,
                  itemCount: cart.orderItems.fold<int>(0, (s, e) => s + e.quantity),
                  onCheckout: () async {
                    final auth = context.read<AuthProvider>();
                    if (auth.user == null) return;

                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                    );

                    if (context.mounted) {
                      await cart.load(auth.user!.id);
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ================= EMPTY (CẬP NHẬT MÀU) =================
  class _EmptyCart extends StatelessWidget {
    const _EmptyCart({this.onBrowse});
    final VoidCallback? onBrowse;

    @override
    Widget build(BuildContext context) {
      final cs = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.orange,),
            const SizedBox(height: 20),
            Text("Giỏ hàng đang trống", style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onBrowse,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange
              ),
              child: const Text("Khám phá ngay"),
            ),
          ],
        ),
      );
    }
  }

/// ================= ITEM (CẬP NHẬT MÀU) =================
class _CartItem extends StatelessWidget {
  const _CartItem({
    required this.product,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final Product product;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = product.price * quantity;
    final money = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // ĐỔI: Màu nền card theo theme
        color: isDark ? cs.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.imageUrl,
              width: 85,
              height: 85,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
                      ),
                    ),
                    IconButton(
                      onPressed: onRemove,
                      icon: Icon(Icons.close, size: 18, color: cs.outline),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                Text(
                  '${money.format(product.price)}',
                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      money.format(total),
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: cs.onSurface),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          _btn(Icons.remove, onDecrease, cs),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('$quantity', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
                          ),
                          _btn(Icons.add, onIncrease, cs),
                        ],
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

  Widget _btn(IconData icon, VoidCallback onTap, ColorScheme cs) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: cs.primary),
      ),
    );
  }
}

/// ================= BOTTOM BAR (CẬP NHẬT MÀU) =================
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.total,
    required this.itemCount,
    required this.onCheckout,
  });

  final double total;
  final int itemCount;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final money = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerLowest : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.4 : 0.1), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tổng cộng", style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                Text(
                  money.format(total),
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: cs.primary),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: onCheckout,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text("THANH TOÁN", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}