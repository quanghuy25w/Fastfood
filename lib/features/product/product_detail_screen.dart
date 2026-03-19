import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_button.dart';
import 'edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isAdding = false;

  Product get product => widget.product;

  /// Navigate to edit screen, then refresh list via provider.
  Future<void> _onEditPressed(BuildContext context) async {
    final productProvider = context.read<ProductProvider>();

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditProductScreen(product: product)),
    );

    if (updated == true) {
      await productProvider.loadProducts();
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    }
  }

  /// Confirm before deleting product and support async loading in dialog.
  Future<void> _onDeletePressed(BuildContext context) async {
    final productId = product.id;
    if (productId == null) {
      return;
    }

    final productProvider = context.read<ProductProvider>();

    final deleted = await ConfirmDialog.show(
      context,
      title: 'Xoa san pham',
      message: 'Ban co chac chan muon xoa san pham nay khong?',
      confirmText: 'Xoa',
      cancelText: 'Huy',
      icon: Icons.delete_forever_outlined,
      isDestructive: true,
      onConfirm: () async {
        await productProvider.deleteProduct(productId);
        final error = productProvider.errorMessage;
        if (error != null) {
          throw Exception(error);
        }
        return true;
      },
    );

    if (!deleted || !context.mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  Future<void> _handleAddToCart() async {
    final productId = product.id;
    if (productId == null) {
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

    setState(() {
      _isAdding = true;
    });

    await cartProvider.addItem(
      CartItem(
        userId: userId,
        productId: productId,
        name: product.name,
        price: product.price,
        quantity: _quantity,
        image: product.image,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isAdding = false;
    });

    if (cartProvider.errorMessage != null) {
      AppHelpers.showErrorSnackBar(context, cartProvider.errorMessage!);
      return;
    }

    AppHelpers.showSuccessSnackBar(context, 'Da them vao gio');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiet mon an'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Sua san pham',
            onPressed: () {
              _onEditPressed(context);
            },
          ),
        ],
      ),
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 280),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 10 * (1 - value)),
              child: child,
            ),
          );
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _ProductImage(imageUrl: product.image),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppFormatters.formatCurrency(product.price),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoTile(
                    label: 'Mo ta',
                    value: product.description ?? 'Mon ngon duoc che bien nhanh',
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    label: 'Danh muc',
                    value: product.categoryId?.toString() ?? 'Khong xac dinh',
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    label: 'Thoi gian tao',
                    value: AppFormatters.formatDateTimeFromString(product.createdAt),
                  ),
                  const SizedBox(height: 20),
                  CustomButton.outline(
                    text: 'Xoa san pham',
                    onPressed: () {
                      _onDeletePressed(context);
                    },
                    fullWidth: true,
                    leadingIcon: const Icon(Icons.delete_outline),
                    borderColor: colors.error.withValues(alpha: 0.5),
                    foregroundColor: colors.error,
                    height: 50,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () {
                              setState(() {
                                _quantity -= 1;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '$_quantity',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _quantity += 1;
                        });
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton.primary(
                  text: 'Add to Cart',
                  onPressed: _handleAddToCart,
                  isLoading: _isAdding,
                  fullWidth: true,
                  trailingIcon: const Icon(Icons.shopping_cart_checkout_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final url = imageUrl?.trim() ?? '';
    final hasImage = url.startsWith('http://') || url.startsWith('https://');

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Container(
        decoration: BoxDecoration(color: colors.secondaryContainer),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.fastfood,
                      size: 56,
                      color: colors.iconAccent,
                    ),
                  );
                },
              )
            : Center(
                child: Icon(Icons.fastfood, size: 56, color: colors.iconAccent),
              ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
