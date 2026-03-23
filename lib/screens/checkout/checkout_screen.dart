import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/address.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../address/address_form_screen.dart';

/// Thanh toán — thiết kế theo chuẩn ShopeeFood/GrabFood, tối ưu conversion.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? _address;
  String _paymentMethod = 'COD';
  final _noteController = TextEditingController();
  bool _submitting = false;
  bool _orderSummaryExpanded = true;

  static final _money = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  /// Phí giao hàng cố định (có thể thay bằng logic theo km/đơn).
  static const double _deliveryFee = 15000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>().user;
      if (auth != null && mounted) {
        setState(() => _address = Address.fromJson(auth.address));
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  double _subtotal(List<OrderItem> items) =>
      items.fold<double>(0, (s, e) => s + e.product.price * e.quantity);

  double _discount(List<OrderItem> items) => 0; // Có thể tích hợp mã giảm giá sau.

  double _total(List<OrderItem> items) =>
      _subtotal(items) + _deliveryFee - _discount(items);

  Future<void> _openAddressForm() async {
    final result = await Navigator.push<Address>(
      context,
      MaterialPageRoute(
        builder: (_) => AddressFormScreen(initialAddress: _address),
      ),
    );
    if (result != null) setState(() => _address = result);
  }

  Future<void> _placeOrder(List<OrderItem> items, int userId) async {
    if (_address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm địa chỉ giao hàng')),
      );
      return;
    }
    if (items.isEmpty) return;

    setState(() => _submitting = true);
    final auth = context.read<AuthProvider>();
    final cartProv = context.read<CartProvider>();
    final nav = Navigator.of(context);
    final mess = ScaffoldMessenger.of(context);
    try {
      final order = await ApiService.instance.placeOrder(
        userId: userId,
        items: items,
        address: '${_address!.recipientName} | ${_address!.phone} | ${_address!.displayString}',
        paymentMethod: _normalizePaymentForApi(_paymentMethod),
        storeNote: _noteController.text.trim(),
      );
      await auth.saveAddress(_address!.toJson());
      if (!mounted) return;
      await cartProv.load(userId);
      if (!mounted) return;
      mess.showSnackBar(const SnackBar(content: Text('Đặt hàng thành công')));
      nav.pop(order);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Consumer2<AuthProvider, CartProvider>(
      builder: (context, auth, cart, _) {
        final user = auth.user;
        final items = cart.orderItems;

        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Thanh toán')),
            body: const Center(child: Text('Vui lòng đăng nhập')),
          );
        }

        if (items.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Thanh toán')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: cs.outline),
                  const SizedBox(height: 16),
                  Text('Giỏ hàng trống', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final subtotal = _subtotal(items);
        final discount = _discount(items);
        final total = _total(items);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Thanh toán'),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 1,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 200),
            children: [
              _DeliveryAddressCard(
                address: _address,
                onTap: _openAddressForm,
                moneyFormat: _money,
              ),
              const SizedBox(height: 20),
              _OrderSummaryCard(
                items: items,
                expanded: _orderSummaryExpanded,
                onToggle: () => setState(() => _orderSummaryExpanded = !_orderSummaryExpanded),
                moneyFormat: _money,
              ),
              const SizedBox(height: 20),
              _PaymentMethodCard(
                selected: _paymentMethod,
                onSelect: (v) => setState(() => _paymentMethod = v),
                paymentMethodToApi: _normalizePaymentForApi,
              ),
              const SizedBox(height: 20),
              _NoteCard(controller: _noteController),
            ],
          ),
          bottomNavigationBar: _CheckoutBottomBar(
            subtotal: subtotal,
            deliveryFee: _deliveryFee,
            discount: discount,
            total: total,
            itemCount: items.length,
            submitting: _submitting,
            onCheckout: () => _placeOrder(items, user.id),
            moneyFormat: _money,
          ),
        );
      },
    );
  }

  String _normalizePaymentForApi(String uiValue) {
    if (uiValue == 'COD') return 'COD';
    return 'WALLET'; // WALLET, BANK đều xử lý như online
  }
}

// ————— 1. Delivery Address Card —————
class _DeliveryAddressCard extends StatelessWidget {
  const _DeliveryAddressCard({
    required this.address,
    required this.onTap,
    required this.moneyFormat,
  });

  final Address? address;
  final VoidCallback onTap;
  final NumberFormat moneyFormat;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context).textTheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.location_on_outlined, color: cs.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Địa chỉ giao hàng',
                  style: theme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: onTap,
                child: const Text('Thay đổi'),
              ),
            ],
          ),
          if (address != null) ...[
            const SizedBox(height: 12),
            Text(
              address!.recipientName,
              style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              address!.phone,
              style: theme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Text(
              address!.displayString,
              style: theme.bodyMedium,
            ),
          ] else ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_location_alt_outlined, color: cs.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Chọn địa chỉ giao hàng',
                      style: theme.bodyLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ————— 2. Order Summary Card (collapsible) —————
class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.items,
    required this.expanded,
    required this.onToggle,
    required this.moneyFormat,
  });

  final List<OrderItem> items;
  final bool expanded;
  final VoidCallback onToggle;
  final NumberFormat moneyFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Đơn hàng (${items.length} món)',
                    style: theme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 24),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.name} × ${item.quantity}',
                        style: theme.bodyMedium,
                      ),
                    ),
                    Text(
                      moneyFormat.format(item.product.price * item.quantity),
                      style: theme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ————— 3. Payment Method Card —————
class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.selected,
    required this.onSelect,
    required this.paymentMethodToApi,
  });

  final String selected;
  final void Function(String) onSelect;
  final String Function(String) paymentMethodToApi;

  static const _methods = [
    ('COD', 'Thanh toán khi nhận (COD)', Icons.money_outlined),
    ('WALLET', 'Ví điện tử', Icons.account_balance_wallet_outlined),
    ('BANK', 'Thẻ ngân hàng', Icons.credit_card_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phương thức thanh toán',
            style: theme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ..._methods.map((m) {
            final id = m.$1;
            final label = m.$2;
            final icon = m.$3;
            final isSelected = id == selected;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelect(id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primary.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? cs.primary : cs.outlineVariant.withOpacity(0.5),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 24,
                          color: isSelected ? cs.primary : cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            label,
                            style: theme.bodyLarge?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: cs.primary, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ————— 4. Note Card —————
class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ghi chú cho cửa hàng',
            style: theme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: ít cay, không hành, giao giờ...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

// ————— 5. Bottom Bar: Price Breakdown + CTA —————
class _CheckoutBottomBar extends StatelessWidget {
  const _CheckoutBottomBar({
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.itemCount,
    required this.submitting,
    required this.onCheckout,
    required this.moneyFormat,
  });

  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final int itemCount;
  final bool submitting;
  final VoidCallback onCheckout;
  final NumberFormat moneyFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PriceRow(label: 'Tạm tính ($itemCount món)', value: subtotal, format: moneyFormat),
            const SizedBox(height: 6),
            _PriceRow(label: 'Phí giao hàng', value: deliveryFee, format: moneyFormat),
            if (discount > 0) ...[
              const SizedBox(height: 6),
              _PriceRow(label: 'Giảm giá', value: -discount, isDiscount: true, format: moneyFormat),
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng thanh toán',
                  style: theme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  moneyFormat.format(total),
                  style: theme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: submitting ? null : onCheckout,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 1,
              ),
              child: submitting
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : Text('Thanh toán ${moneyFormat.format(total)}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    required this.format,
    this.isDiscount = false,
  });

  final String label;
  final double value;
  final NumberFormat format;
  final bool isDiscount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        Text(
          isDiscount ? '-${format.format(value.abs())}' : format.format(value),
          style: theme.bodyMedium?.copyWith(
            color: isDiscount ? Colors.green : null,
          ),
        ),
      ],
    );
  }
}

// ————— Shared Card —————
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
