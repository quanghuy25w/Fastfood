import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../checkout/checkout_screen.dart';

/// Chi tiết đơn hàng — thiết kế theo chuẩn ShopeeFood/GrabFood.
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});

  final Order order;

  static final _money = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
  static final _df = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final timeline = _timelineIndex(order.status);
    final eta = order.createdAt.add(const Duration(minutes: 35));
    final subTotal = order.items.fold<double>(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
    final canCancel = timeline < 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn #${order.id}'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
        children: [
          _OrderStatusCard(
            currentStep: timeline,
            eta: eta,
          ),
          const SizedBox(height: 16),
          _OrderInfoCard(order: order, moneyFormat: _money, dateFormat: _df),
          const SizedBox(height: 16),
          _OrderItemsCard(items: order.items, subTotal: subTotal, moneyFormat: _money),
          const SizedBox(height: 16),
          if (order.storeNote.trim().isNotEmpty) ...[
            _NoteCard(note: order.storeNote.trim()),
            const SizedBox(height: 16),
          ],
          _DeliveryAddressCard(address: order.address),
        ],
      ),
      bottomNavigationBar: _ActionBar(
        canCancel: canCancel,
        onCall: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đang gọi shipper...')),
          );
        },
        onCancel: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yêu cầu hủy đã gửi')),
          );
        },
        onReorder: () async {
          final auth = context.read<AuthProvider>().user;
          final cart = context.read<CartProvider>();
          if (auth == null) return;
          for (final item in order.items) {
            await cart.addProduct(item.product, quantity: item.quantity);
          }
          if (!context.mounted) return;
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CheckoutScreen()),
          );
          if (context.mounted) await cart.load(auth.id);
        },
      ),
    );
  }
}

int _timelineIndex(String status) {
  switch (status) {
    case 'pending':
      return 0;
    case 'confirmed':
      return 1;
    case 'shipping':
      return 2;
    case 'completed':
      return 3;
    default:
      return 0;
  }
}

// ————— 1. Order Status Card —————
class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard({required this.currentStep, required this.eta});

  final int currentStep;
  final DateTime eta;

  static const _labels = ['Đã đặt', 'Đang chuẩn bị', 'Đang giao', 'Hoàn thành'];
  static const _icons = [
    Icons.receipt_long_outlined,
    Icons.restaurant_outlined,
    Icons.delivery_dining_outlined,
    Icons.check_circle_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: cs.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Trạng thái đơn hàng',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(_labels.length, (index) {
              final done = index <= currentStep;
              final isLast = index == _labels.length - 1;
              final color = done
                  ? (isLast ? Colors.green : cs.primary)
                  : cs.onSurfaceVariant;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withOpacity(done ? 0.15 : 0.08),
                              shape: BoxShape.circle,
                              border: done
                                  ? Border.all(color: color, width: 1.5)
                                  : null,
                            ),
                            child: Icon(
                              _icons[index],
                              size: 20,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _labels[index],
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: color,
                                  fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (index < _labels.length - 1)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 28),
                          child: Container(
                            height: 2,
                            color: index < currentStep
                                ? (isLast ? Colors.green : cs.primary).withOpacity(0.5)
                                : cs.outlineVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, size: 20, color: cs.primary),
                const SizedBox(width: 10),
                Text(
                  'Dự kiến giao: ${DateFormat('HH:mm').format(eta)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ————— 2. Order Info Card —————
class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard({
    required this.order,
    required this.moneyFormat,
    required this.dateFormat,
  });

  final Order order;
  final NumberFormat moneyFormat;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _InfoRow(label: 'Mã đơn', value: '#${order.id}'),
          _InfoRow(
            label: 'Tổng tiền',
            value: moneyFormat.format(order.totalAmount),
            isHighlight: true,
          ),
          _InfoRow(
            label: 'Thanh toán',
            value: order.paymentMethod == 'COD' ? 'COD (khi nhận)' : 'Đã thanh toán',
          ),
          _InfoRow(
            label: 'Thời gian đặt',
            value: dateFormat.format(order.createdAt),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ————— 3. Order Items Card —————
class _OrderItemsCard extends StatelessWidget {
  const _OrderItemsCard({
    required this.items,
    required this.subTotal,
    required this.moneyFormat,
  });

  final List<OrderItem> items;
  final double subTotal;
  final NumberFormat moneyFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Món đã đặt',
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.product.imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        color: cs.surfaceContainerHighest,
                        child: Icon(Icons.fastfood_outlined, color: cs.outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${moneyFormat.format(item.product.price)} × ${item.quantity}',
                          style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    moneyFormat.format(item.product.price * item.quantity),
                    style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tạm tính',
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
              Text(
                moneyFormat.format(subTotal),
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ————— 4. Note Card —————
class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.edit_note_outlined, color: cs.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ghi chú cho cửa hàng',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  note,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ————— 5. Delivery Address Card —————
class _DeliveryAddressCard extends StatelessWidget {
  const _DeliveryAddressCard({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Địa chỉ giao hàng',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  address,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ————— Action Bar (bottom) —————
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.canCancel,
    required this.onCall,
    required this.onCancel,
    required this.onReorder,
  });

  final bool canCancel;
  final VoidCallback onCall;
  final VoidCallback onCancel;
  final VoidCallback onReorder;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: cs.surface,
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
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.call_outlined, size: 18),
              label: const Text('Gọi'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: canCancel ? onCancel : null,
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Hủy đơn'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: onReorder,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Đặt lại'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ————— Shared components —————
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isHighlight;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
              ),
            ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          Text(
            value,
            style: isHighlight
                ? theme.textTheme.titleMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w800,
                  )
                : theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
