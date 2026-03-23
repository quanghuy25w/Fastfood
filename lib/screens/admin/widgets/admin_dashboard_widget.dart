import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/api_service.dart';

class AdminDashboardWidget extends StatelessWidget {
  const AdminDashboardWidget({super.key, required this.summary});

  final AdminDashboardSummary summary;

  static final _money = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 112,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _SummaryCard(
                title: 'Sản phẩm',
                value: '${summary.totalProducts}',
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(width: 12),
              _SummaryCard(
                title: 'Đơn hàng',
                value: '${summary.totalOrders}',
                icon: Icons.receipt_long_outlined,
              ),
              const SizedBox(width: 12),
              _SummaryCard(
                title: 'Doanh thu',
                value: _money.format(summary.revenue),
                icon: Icons.payments_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
