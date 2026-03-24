import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/address.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../address/address_form_screen.dart';

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

  static final _money = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );
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

  double _discount(List<OrderItem> items) => 0;

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
        address:
            '${_address!.recipientName} | ${_address!.phone} | ${_address!.displayString}',
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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

        if (user == null)
          return const Scaffold(
            body: Center(child: Text('Vui lòng đăng nhập')),
          );
        if (items.isEmpty)
          return Scaffold(
            appBar: AppBar(title: const Text('Thanh toán')),
            body: const Center(child: Text('Giỏ hàng trống')),
          );

        final subtotal = _subtotal(items);
        final discount = _discount(items);
        final total = _total(items);

        return Scaffold(
          appBar: AppBar(title: const Text('Thanh toán'), centerTitle: true),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 320),
            children: [
              // 1. Địa chỉ
              _SectionHeader(
                icon: Icons.location_on_rounded,
                title: 'Địa chỉ giao hàng',
                color: cs.primary,
              ),
              const SizedBox(height: 12),
              _DeliveryAddressCard(
                address: _address,
                onTap: _openAddressForm,
                moneyFormat: _money,
              ),
              const SizedBox(height: 32),

              // 2. Sản phẩm
              _SectionHeader(
                icon: Icons.shopping_bag_rounded,
                title: 'Sản phẩm đặt hàng',
                color: cs.primary,
              ),
              const SizedBox(height: 12),
              _OrderItemsDetailedCard(
                items: items,
                expanded: _orderSummaryExpanded,
                onToggle: () => setState(
                  () => _orderSummaryExpanded = !_orderSummaryExpanded,
                ),
                moneyFormat: _money,
              ),
            ],
          ),
          bottomNavigationBar: _CheckoutBottomBar(
            subtotal: subtotal,
            deliveryFee: _deliveryFee,
            discount: discount,
            total: total,
            itemCount: items.length,
            submitting: _submitting,
            paymentMethod: _paymentMethod,
            onPaymentMethodSelect: (v) => setState(() => _paymentMethod = v),
            noteController: _noteController,
            onCheckout: () => _placeOrder(items, user.id),
            moneyFormat: _money,
          ),
        );
      },
    );
  }

  String _normalizePaymentForApi(String uiValue) =>
      uiValue == 'COD' ? 'COD' : 'WALLET';
}

// --- Các Widget hỗ trợ (Headers, Cards, v.v.) ---

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });
  final IconData icon;
  final String title;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: address == null
          ? InkWell(
              onTap: onTap,
              child: Center(
                child: Text(
                  '+ Thêm địa chỉ',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      address!.recipientName,
                      style: theme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    InkWell(
                      onTap: onTap,
                      child: Text(
                        'Thay đổi',
                        style: TextStyle(color: cs.primary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(address!.phone, style: theme.bodySmall),
                Text(
                  address!.displayString,
                  style: theme.bodySmall,
                  maxLines: 2,
                ),
              ],
            ),
    );
  }
}

class _OrderItemsDetailedCard extends StatelessWidget {
  const _OrderItemsDetailedCard({
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onToggle,
            title: Text('${items.length} sản phẩm'),
            trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
          ),
          if (expanded)
            ...items.map(
              (item) => ListTile(
                title: Text(item.product.name),
                subtitle: Text(
                  '${moneyFormat.format(item.product.price)} x ${item.quantity}',
                ),
                trailing: Text(
                  moneyFormat.format(item.product.price * item.quantity),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- BOTTOM BAR ĐẦY ĐỦ CÁC THÀNH PHẦN ---
class _CheckoutBottomBar extends StatelessWidget {
  const _CheckoutBottomBar({
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.itemCount,
    required this.submitting,
    required this.paymentMethod,
    required this.onPaymentMethodSelect,
    required this.noteController,
    required this.onCheckout,
    required this.moneyFormat,
  });

  final double subtotal, deliveryFee, discount, total;
  final int itemCount;
  final bool submitting;
  final String paymentMethod;
  final Function(String) onPaymentMethodSelect;
  final TextEditingController noteController;
  final VoidCallback onCheckout;
  final NumberFormat moneyFormat;

  static const _methods = [
    ('COD', 'Tiền mặt', Icons.money),
    ('WALLET', 'Ví', Icons.wallet),
    ('BANK', 'Thẻ', Icons.credit_card),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Hình thức thanh toán', style: theme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: _methods
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(m.$2),
                      selected: paymentMethod == m.$1,
                      onSelected: (_) => onPaymentMethodSelect(m.$1),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            decoration: InputDecoration(
              hintText: 'Ghi chú...',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PriceRow(label: 'Tạm tính', value: subtotal, format: moneyFormat),
          _PriceRow(
            label: 'Phí giao hàng',
            value: deliveryFee,
            format: moneyFormat,
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng',
                style: theme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                moneyFormat.format(total),
                style: theme.titleLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: submitting ? null : onCheckout,
            child: submitting
                ? const CircularProgressIndicator()
                : const Text('Thanh toán'),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    required this.format,
  });
  final String label;
  final double value;
  final NumberFormat format;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(format.format(value), style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
