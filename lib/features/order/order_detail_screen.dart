import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/loading_widget.dart';
import '../../providers/order_provider.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiet don hang')),
      body: FutureBuilder(
        future: context.read<OrderProvider>().getOrderById(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget.medium(
              message: 'Đang tải chi tiếp đơn...',
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Loi: ${snapshot.error}'));
          }

          final order = snapshot.data;
          if (order == null) {
            return const Center(child: Text('Khong tim thay don hang'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id ?? '-'}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        label: 'Tong tien',
                        value: AppFormatters.formatCurrency(order.totalAmount),
                        valueColor: colors.primary,
                      ),
                      _InfoRow(
                        label: 'Dia chi',
                        value: order.address.fullAddress,
                      ),
                      if (order.address.label != null &&
                          order.address.label!.trim().isNotEmpty)
                        _InfoRow(
                          label: 'Nhan',
                          value: order.address.label!.trim(),
                        ),
                      _InfoRow(
                        label: 'Ngay tao',
                        value: AppFormatters.formatDateTimeFromString(
                          order.createdAt,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('San pham', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...order.orderItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        AppFormatters.formatQuantity(item.quantity),
                      ),
                      trailing: Text(
                        AppFormatters.formatCurrency(item.subtotal),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.w700 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
