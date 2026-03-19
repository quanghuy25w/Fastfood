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
      AppHelpers.showWarningSnackBar(context, 'Gio hang dang trong');
      return;
    }

    final checkoutAddress = _resolveSelectedAddress(addressProvider);
    if (checkoutAddress == null) {
      AppHelpers.showWarningSnackBar(
        context,
        'Vui long chon dia chi giao hang',
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

      AppHelpers.showSuccessSnackBar(context, 'Thanh toan thanh cong');
      AppHelpers.popToRoot(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      final errorMessage = AppHelpers.parseErrorMessage(e);
      AppHelpers.showErrorSnackBar(
        context,
        'Thanh toan that bai: $errorMessage',
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
    final cartProvider = context.watch<CartProvider>();
    final addressProvider = context.watch<AddressProvider>();

    final items = cartProvider.items;
    final totalPrice = cartProvider.totalPrice;
    final addresses = addressProvider.addresses;
    final resolvedAddress = _resolveSelectedAddress(addressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Dang xu ly thanh toan...',
        child: items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.remove_shopping_cart_outlined,
                        size: 52,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Chua co san pham trong gio',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                children: [
                  _CheckoutSection(
                    title: 'Dia chi giao hang',
                    actionLabel: 'Doi dia chi',
                    onActionTap: _isLoading ? null : _openAddressSelector,
                    child: addresses.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Chua co dia chi giao hang'),
                              const SizedBox(height: 10),
                              CustomButton.secondary(
                                text: 'Them dia chi',
                                onPressed: _isLoading ? null : _openAddressSelector,
                                width: 160,
                                height: 44,
                                leadingIcon:
                                    const Icon(Icons.add_location_alt_outlined),
                              ),
                            ],
                          )
                        : _AddressTile(
                            address: resolvedAddress,
                            onTap: _isLoading ? null : _openAddressSelector,
                          ),
                  ),
                  const SizedBox(height: 12),
                  _CheckoutSection(
                    title: 'Mon da chon (${items.length})',
                    child: Column(
                      children: items.map((item) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: item == items.last ? 0 : 10,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: colors.secondaryContainer,
                                child: Icon(
                                  Icons.fastfood_rounded,
                                  color: colors.iconAccent,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${AppFormatters.formatCurrency(item.price)} x ${item.quantity}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                AppFormatters.formatCurrency(item.subtotal),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _CheckoutSection(
                    title: 'Tong thanh toan',
                    child: Row(
                      children: [
                        const Expanded(child: Text('Tong cong')),
                        Text(
                          AppFormatters.formatCurrency(totalPrice),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                          ),
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
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: CustomButton.primary(
            text: 'Xac nhan thanh toan',
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

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (actionLabel != null)
                  TextButton(
                    onPressed: onActionTap,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(10, 10),
                    ),
                    child: Text(actionLabel!),
                  ),
              ],
            ),
            const SizedBox(height: 10),
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: address == null
            ? const Text('Vui long chon dia chi giao hang')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address!.recipientName.trim().isEmpty
                        ? 'Nguoi nhan'
                        : address!.recipientName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.formatPhone(
                      address!.phone,
                      fallback: 'Chua cap nhat so dien thoai',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(address!.fullAddress),
                  if (address!.label != null &&
                      address!.label!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Chip(
                        label: Text(address!.label!.trim()),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
