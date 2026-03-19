import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/address_model.dart';
import '../../data/models/order_model.dart';
import '../../providers/address_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../address/address_list_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? selectedAddress;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (selectedAddress == null) {
      final provider = context.read<AddressProvider>();
      final resolved = _resolveSelectedAddress(provider);
      if (resolved != null) {
        selectedAddress = resolved;
      }
    }
  }

  Address? _resolveSelectedAddress(AddressProvider provider) {
    return selectedAddress ??
        provider.selectedAddress ??
        (provider.addresses.isNotEmpty ? provider.addresses.first : null);
  }

  Future<void> _openAddressSelector() async {
    final selected = await Navigator.of(context).push<Address>(
      MaterialPageRoute(
        builder: (_) => const AddressListScreen(isCheckoutSelection: true),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    context.read<AddressProvider>().selectAddress(selected);
    setState(() {
      selectedAddress = selected;
    });
  }

  /// Create order, persist to DB, then clear cart.
  Future<void> _handleCheckout() async {
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final addressProvider = context.read<AddressProvider>();

    if (AppHelpers.isNullOrEmptyList(cartProvider.items)) {
      AppHelpers.showWarningSnackBar(context, 'Giỏ hàng đang trống');
      return;
    }

    final checkoutAddress = _resolveSelectedAddress(addressProvider);
    if (checkoutAddress == null) {
      AppHelpers.showWarningSnackBar(
        context,
        'Vui lòng chọn địa chỉ giao hàng',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final order = Order(
        items: List.of(cartProvider.items),
        totalAmount: cartProvider.totalPrice,
        address: checkoutAddress,
        createdAt: DateTime.now().toIso8601String(),
      );

      await orderProvider.addOrder(order);

      final checkoutUserId =
          cartProvider.activeUserId ??
          (cartProvider.items.isNotEmpty
              ? (cartProvider.items.first.userId ?? 0)
              : 0);

      await cartProvider.clearCart(checkoutUserId);

      if (!mounted) {
        return;
      }

      AppHelpers.showSuccessSnackBar(context, 'Thanh toán thành công');
      AppHelpers.popToRoot(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      final errorMessage = AppHelpers.parseErrorMessage(e);
      AppHelpers.showErrorSnackBar(
        context,
        'Thanh toán thất bại: $errorMessage',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final cartProvider = context.watch<CartProvider>();
    final addressProvider = context.watch<AddressProvider>();

    final items = cartProvider.items;
    final totalPrice = cartProvider.totalPrice;
    final addresses = addressProvider.addresses;
    final resolvedAddress = _resolveSelectedAddress(addressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Đang xử lý thanh toán...',
        child: items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 56,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Giỏ hàng trống',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 150),
                children: [
                  // Address section
                  _CheckoutSection(
                    title: 'Địa chỉ giao hàng',
                    actionLabel: 'Th᪪y đổi',
                    onActionTap: _isLoading ? null : _openAddressSelector,
                    child: addresses.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Chúa có địa chỉ giao hàng'),
                              const SizedBox(height: 12),
                              CustomButton.secondary(
                                text: 'Thêm địa chỉ',
                                onPressed: _isLoading
                                    ? null
                                    : _openAddressSelector,
                                width: 160,
                                height: 44,
                                leadingIcon: const Icon(
                                  Icons.add_location_alt_outlined,
                                ),
                              ),
                            ],
                          )
                        : _AddressTile(
                            address: resolvedAddress,
                            onTap: _isLoading ? null : _openAddressSelector,
                          ),
                  ),
                  const SizedBox(height: 14),
                  // Items section
                  _CheckoutSection(
                    title: '${items.length} món đã chọn',
                    child: Column(
                      children: items.map((item) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: item == items.last ? 0 : 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: colors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.fastfood_rounded,
                                  color: colors.iconAccent,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${AppFormatters.formatCurrency(item.price)} × ${item.quantity}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                AppFormatters.formatCurrency(item.subtotal),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Total section
                  _CheckoutSection(
                    title: 'Tổng thanh toán',
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tổng cộng', style: theme.textTheme.bodyLarge),
                            Text(
                              AppFormatters.formatCurrency(totalPrice),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
          child: CustomButton.primary(
            text: 'Xác nhận thanh toán',
            onPressed: _handleCheckout,
            enabled: !_isLoading && items.isNotEmpty,
            fullWidth: true,
            leadingIcon: const Icon(Icons.payments_outlined),
          ),
        ),
      ),
    );
  }
}

class _CheckoutSection extends StatelessWidget {
  const _CheckoutSection({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1.2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (actionLabel != null)
                  TextButton(
                    onPressed: onActionTap,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(10, 10),
                    ),
                    child: Text(
                      actionLabel!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address, this.onTap});

  final Address? address;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(14),
          color: colors.surface,
        ),
        child: address == null
            ? Text(
                'Chọn địa chỉ giao hàng',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address!.recipientName.trim().isEmpty
                        ? 'Nguoi nhan'
                        : address!.recipientName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppFormatters.formatPhone(
                      address!.phone,
                      fallback: 'Chua cap nhat so dien thoai',
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    address!.fullAddress,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  if (address!.label != null &&
                      address!.label!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        address!.label!.trim(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
