import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/helpers.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/cart_item_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  /// Confirm before removing an item from cart.
  Future<void> _confirmDelete(
    BuildContext context,
    CartProvider cartProvider,
    int productId,
  ) async {
    await ConfirmDialog.show(
      context,
      title: 'Xoá sản phẩm',
      message: 'Bạn có chắc chắn muốn xoá sản phẩm khỏi giỏ hàng không?',
      confirmText: 'Xoa',
      cancelText: 'Huy',
      icon: Icons.delete_outline,
      isDestructive: true,
      onConfirm: () async {
        await cartProvider.removeItem(productId);
        final error = cartProvider.errorMessage;
        if (error != null) {
          throw Exception(error);
        }
        return true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    // Load cart state from Provider.
    final cartProvider = context.watch<CartProvider>();
    final items = cartProvider.items;
    final totalPrice = cartProvider.totalPrice;

    final Widget content = AppHelpers.isNullOrEmptyList(items)
        ? _EmptyCart(
            onGoMenu: () {
              Navigator.of(context).pushNamed(AppRoutes.productList);
            },
          )
        : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 200),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = items[index];

              return CartItemWidget(
                item: item,
                onIncrease: () {
                  cartProvider.increaseQuantity(item.productId);
                },
                onDecrease: () {
                  cartProvider.decreaseQuantity(item.productId);
                },
                onDelete: () {
                  _confirmDelete(context, cartProvider, item.productId);
                },
              );
            },
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Gio hang cua ban')),
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 8 * (1 - value)),
              child: child,
            ),
          );
        },
        child: LoadingOverlay(
          isLoading: cartProvider.isLoading,
          message: 'Dang cap nhat gio hang...',
          child: Column(
            children: [
              if (cartProvider.errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.12),
                    border: Border.all(
                      color: colors.error.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: colors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cartProvider.errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(child: content),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Items info
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tong tien',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${items.length} mon',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Total price
              Text(
                AppFormatters.formatCurrency(totalPrice),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              // Checkout button
              CustomButton.primary(
                text: 'Thanh toan',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                },
                enabled: AppHelpers.hasItems(items) && !cartProvider.isLoading,
                fullWidth: true,
                trailingIcon: const Icon(Icons.arrow_forward_rounded, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onGoMenu});

  final VoidCallback onGoMenu;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 40,
                color: colors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gio hang trong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hay chon mon an yeu thich de dat hang',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            CustomButton.secondary(
              text: 'Xem menu',
              onPressed: onGoMenu,
              width: 180,
              leadingIcon: const Icon(Icons.restaurant_menu_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
