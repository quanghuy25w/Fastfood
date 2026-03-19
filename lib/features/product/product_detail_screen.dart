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
      title: 'Xoá sản phẩm',
      message: 'Bạn có chắc chắn muốn xoá sản phẩm này không?',
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
      AppHelpers.showErrorSnackBar(
        context,
        'Không thể thêm sản phẩm này vào giỏ',
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();
    final userId = authProvider.currentUser?.id ?? cartProvider.activeUserId;

    if (userId == null) {
      AppHelpers.showWarningSnackBar(context, 'Vui lòng đăng nhập để đặt hàng');
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiếp món ăn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Sửa sản phẩm',
            onPressed: () {
              _onEditPressed(context);
            },
          ),
        ],
      ),
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 280),
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _ProductImage(imageUrl: product.image),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppFormatters.formatCurrency(product.price),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _InfoTile(
                    label: 'Mo ta',
                    value:
                        product.description ?? 'Mon ngon duoc che bien nhanh',
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    label: 'Danh muc',
                    value: product.categoryId?.toString() ?? 'Khong xac dinh',
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    label: 'Thoi gian tao',
                    value: AppFormatters.formatDateTimeFromString(
                      product.createdAt,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton.outline(
                    text: 'Xoá sản phẩm',
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Quantity control
              Container(
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                      splashRadius: 20,
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _quantity += 1;
                        });
                      },
                      icon: const Icon(Icons.add),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Add to cart button
              Expanded(
                child: CustomButton.primary(
                  text: 'Them vao gio',
                  onPressed: _handleAddToCart,
                  isLoading: _isAdding,
                  fullWidth: true,
                  trailingIcon: const Icon(
                    Icons.shopping_cart_checkout_outlined,
                  ),
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
      aspectRatio: 1 / 1.1,
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
                      Icons.fastfood_rounded,
                      size: 80,
                      color: colors.iconAccent,
                    ),
                  );
                },
              )
            : Center(
                child: Icon(
                  Icons.fastfood_rounded,
                  size: 80,
                  color: colors.iconAccent,
                ),
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
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
