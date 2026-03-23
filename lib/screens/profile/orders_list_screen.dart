import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/order.dart';
import '../../services/api_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/chip_bar.dart';
import 'order_detail_screen.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key, required this.userId});

  final int userId;

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  late Future<List<Order>> _future;
  String? _selectedStatus;

  static const _statusChips = ['Tất cả', 'Chờ xác nhận', 'Đã xác nhận', 'Đang giao', 'Hoàn thành', 'Đã hủy'];

  static String _statusToChip(String status) {
    final s = status.toLowerCase();
    if (s.contains('pend') || s.contains('chờ')) return 'Chờ xác nhận';
    if (s.contains('confirm') || s.contains('xác nhận')) return 'Đã xác nhận';
    if (s.contains('ship') || s.contains('giao')) return 'Đang giao';
    if (s.contains('complete') || s.contains('hoàn thành')) return 'Hoàn thành';
    if (s.contains('cancel') || s.contains('hủy')) return 'Đã hủy';
    return status;
  }

  static bool _orderMatchesStatus(Order o, String? chip) {
    if (chip == null || chip == 'Tất cả') return true;
    return _statusToChip(o.status) == chip;
  }

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getOrdersByUser(widget.userId);
  }

  static final _money = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
  static final _df = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: cs.primary,
        onRefresh: () async {
          final next = ApiService.instance.getOrdersByUser(widget.userId);
          setState(() {
            _future = next;
          });
          await next;
        },
        child: FutureBuilder<List<Order>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator(color: cs.primary));
            }
            final list = snap.data ?? [];
            final filtered = list.where((o) => _orderMatchesStatus(o, _selectedStatus)).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        const AppHeader(subtitle: 'Xem lịch sử và theo dõi đơn hàng'),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: AppSearchBar(hint: 'Tìm đơn hàng'),
                        ),
                        const SizedBox(height: 16),
                        ChipBar(
                          items: _statusChips,
                          selected: _selectedStatus,
                          onSelect: (v) => setState(() => _selectedStatus = v == 'Tất cả' ? null : v),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        list.isEmpty ? 'Chưa có đơn hàng' : 'Không có đơn nào phù hợp',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final o = filtered[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              color: cs.surface,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(color: cs.outlineVariant),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                title: Text(
                                  'Đơn #${o.id}',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: cs.onSurface,
                                      ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${_df.format(o.createdAt)} · ${o.status}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                                trailing: Text(
                                  _money.format(o.totalAmount),
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: cs.primary,
                                      ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => OrderDetailScreen(order: o)),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
