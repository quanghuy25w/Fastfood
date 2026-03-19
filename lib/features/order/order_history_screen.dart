import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/loading_widget.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      context.read<OrderProvider>().fetchOrders(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Lich su don hang')),
      body: provider.isLoading
          ? const LoadingWidget.medium(message: 'Đang tải đơn hàng...')
          : provider.orders.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Chua co don hang nao',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.orders.length,
              itemBuilder: (context, index) {
                final order = provider.orders[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      title: Text('Order #${order.id ?? '-'}'),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Tong: ${AppFormatters.formatCurrency(order.totalAmount)}\n'
                          'Ngay: ${AppFormatters.formatDateTimeFromString(order.createdAt)}',
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: order.id == null
                          ? null
                          : () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.orderDetail,
                                arguments: order.id,
                              );
                            },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
