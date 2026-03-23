import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'product_management_screen.dart';
import 'widgets/admin_dashboard_widget.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late Future<AdminDashboardSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = ApiService.instance.getAdminDashboardSummary();
  }

  Future<void> _refresh() async {
    final next = ApiService.instance.getAdminDashboardSummary();
    setState(() => _summaryFuture = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: cs.primary,
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder<AdminDashboardSummary>(
              future: _summaryFuture,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator(color: cs.primary)),
                  );
                }
                return AdminDashboardWidget(
                  summary: snap.data ??
                      const AdminDashboardSummary(
                        totalProducts: 0,
                        totalOrders: 0,
                        revenue: 0,
                      ),
                );
              },
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: cs.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản trị chính',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProductManagementScreen()),
                        );
                        if (mounted) _refresh();
                      },
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('Quản lý sản phẩm'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
