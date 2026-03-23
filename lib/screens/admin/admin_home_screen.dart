// lib/screens/admin/admin_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';
import 'product_management_screen.dart';
import 'order_management_screen.dart';
import 'user_management_screen.dart';
import 'product_form_screen.dart';
import 'widgets/header_widget.dart';
import 'widgets/horizontal_stat_card.dart';
import 'widgets/action_card.dart';
import 'widgets/activity_item.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late Future<AdminDashboardSummary> _dashboardFuture;
  late Future<List<Map<String, dynamic>>> _recentActivityFuture;
  final DatabaseService _db = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dashboardFuture = ApiService.instance.getAdminDashboardSummary();
    _recentActivityFuture = _getRecentActivity();
  }

  Future<void> _refresh() async {
    setState(() => _loadData());
    await Future.wait([_dashboardFuture, _recentActivityFuture]);
  }

  Future<List<Map<String, dynamic>>> _getRecentActivity() async {
    final db = await _db.database;
    
    // Get recent orders
    final orders = await db.query(
      'orders',
      orderBy: 'created_at DESC',
      limit: 3,
    );

    // Get recent products
    final products = await db.query(
      'products',
      orderBy: 'id DESC',
      limit: 2,
    );

    List<Map<String, dynamic>> activities = [];

    for (var order in orders) {
      activities.add({
        'type': 'order',
        'title': 'Đơn hàng #${order['id']}',
        'subtitle': 'Order created - ${order['status']}',
        'timestamp': _formatTime(order['created_at'] as String?),
      });
    }

    for (var product in products) {
      activities.add({
        'type': 'product',
        'title': product['name'] as String,
        'subtitle': 'sản phẩm mới được thêm',
        'timestamp': 'vừa xong',
      });
    }

    activities.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    return activities.take(5).toList();
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return 'Vừa xong';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Vừa xong';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m trước';
      if (diff.inHours < 24) return '${diff.inHours}h trước';
      return '${diff.inDays}d trước';
    } catch (e) {
      return 'Vừa xong';
    }
  }

  String _formatRevenue(double revenue) {
    if (revenue >= 1000000) {
      return '${(revenue / 1000000).toStringAsFixed(1)}M₫';
    } else if (revenue >= 1000) {
      return '${(revenue / 1000).toStringAsFixed(1)}K₫';
    }
    return '${revenue.toStringAsFixed(0)}₫';
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined, color: Color(0xFF4F46E5)),
              title: const Text('Thêm sản phẩm'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductFormScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined, color: Color(0xFF4F46E5)),
              title: const Text('Thêm đơn hàng'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF2A2A3E) : Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleLightDark();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.logout_outlined,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        backgroundColor: const Color(0xFF4F46E5),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF4F46E5),
        child: FutureBuilder<AdminDashboardSummary>(
          future: _dashboardFuture,
          builder: (context, dashSnap) {
            if (dashSnap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final dashData = dashSnap.data ??
                const AdminDashboardSummary(
                  totalProducts: 0,
                  totalOrders: 0,
                  revenue: 0,
                );

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                /// ===== HEADER =====
                HeaderWidget(
                  userName: user?.name ?? 'Admin',
                  avatarUrl: null,
                ),

                const SizedBox(height: 24),

              

                const SizedBox(height: 28),

                /// ===== QUICK STATS (HORIZONTAL SCROLL) =====
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      HorizontalStatCard(
                        label: 'Tổng sản phẩm',
                        value: '${dashData.totalProducts}',
                        icon: Icons.inventory_2_outlined,
                        color: const Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 12),
                      HorizontalStatCard(
                        label: 'Tổng đơn hàng',
                        value: '${dashData.totalOrders}',
                        icon: Icons.receipt_long_outlined,
                        color: const Color(0xFF2196F3),
                      ),
                      const SizedBox(width: 12),
                      HorizontalStatCard(
                        label: 'Doanh thu',
                        value: _formatRevenue(dashData.revenue),
                        icon: Icons.trending_up_outlined,
                        color: const Color(0xFF22C55E),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// ===== QUICK ACTIONS (HORIZONTAL SCROLL) =====
                SizedBox(
                  height: 130,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      SizedBox(
                        width: 100,
                        child: ActionCard(
                          label: 'Sản phẩm',
                          icon: Icons.inventory_2_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProductManagementScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: ActionCard(
                          label: 'Đơn hàng',
                          icon: Icons.receipt_long_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OrderManagementScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: ActionCard(
                          label: 'Tài khoản',
                          icon: Icons.people_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UserManagementScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: ActionCard(
                          label: 'Thống kê',
                          icon: Icons.bar_chart_outlined,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tính năng đang phát triển'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// ===== RECENT ACTIVITY SECTION =====
                Text(
                  'Hoạt động gần đây',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                ),

                const SizedBox(height: 14),

                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _recentActivityFuture,
                  builder: (context, actSnap) {
                    if (actSnap.connectionState != ConnectionState.done) {
                      return const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final activities = actSnap.data ?? [];

                    if (activities.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Chưa có hoạt động nào',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: List.generate(
                        activities.length,
                        (index) {
                          final activity = activities[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < activities.length - 1 ? 12 : 0,
                            ),
                            child: ActivityItem(
                              title: activity['title'],
                              subtitle: activity['subtitle'],
                              icon: activity['type'] == 'order'
                                  ? Icons.receipt_long_outlined
                                  : Icons.inventory_2_outlined,
                              iconColor: activity['type'] == 'order'
                                  ? const Color(0xFF2196F3)
                                  : const Color(0xFFFF9800),
                              timestamp: activity['timestamp'],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                /// ===== FOOTER (OPTIONAL) =====
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Mini Shop v1.0 | Phiên bản quản trị',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[500],
                          ),
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