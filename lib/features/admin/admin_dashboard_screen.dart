import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/confirm_dialog.dart';

/// Admin dashboard để quản lý đơn hàng và người dùng đã đặt.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final authProvider = context.read<AuthProvider>();

    // ⚠️ Nếu bạn có API admin → nên dùng fetchAllOrders()
    if (authProvider.currentUser?.id != null) {
      context
          .read<OrderProvider>()
          .fetchOrders(authProvider.currentUser!.id!);
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await ConfirmDialog.show(
      context,
      title: 'Đăng xuất',
      message: 'Bạn có chắc chắn muốn đăng xuất không?',
      confirmText: 'Đăng xuất',
      cancelText: 'Hủy',
      icon: Icons.logout,
      onConfirm: () async {
        context.read<AuthProvider>().logout();
        return true;
      },
    );

    if (!shouldLogout || !context.mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    final username =
        authProvider.currentUser?.name ??
        authProvider.currentUser?.email ??
        'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Xin chào, $username',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Cài đặt'),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(AppRoutes.settings);
                },
              ),
              PopupMenuItem(
                child: const Text('Đăng xuất'),
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        ],
      ),

      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.orders.isEmpty
              ? _buildEmptyState(colors, theme)
              : RefreshIndicator(
                  onRefresh: () async => _loadOrders(), // ✅ FIX
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: orderProvider.orders.length,
                    itemBuilder: (context, index) {
                      final order = orderProvider.orders[index];
                      return _buildOrderCard(
                        context,
                        order,
                        colors,
                        theme,
                      );
                    },
                  ),
                ),
    );
  }

  /// UI khi chưa có đơn hàng
  Widget _buildEmptyState(AppColorPalette colors, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_outlined,
              size: 56,
              color: colors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có đơn hàng',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card hiển thị đơn hàng
  Widget _buildOrderCard(
    BuildContext context,
    dynamic order,
    AppColorPalette colors,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1.2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đơn hàng #${order.id}',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ngày: ${AppFormatters.formatDateTimeFromString(order.createdAt)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                /// STATUS BADGE (FIX COLOR)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer, // ✅ FIX
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Xác nhận',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(
                      color: colors.onPrimaryContainer, // ✅ FIX
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// ADDRESS
            Text(
              'Địa chỉ giao hàng',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),

            /// ✅ FIX ADDRESS
            Text(
              _formatAddress(order.address),
              style: theme.textTheme.bodySmall,
            ),

            const SizedBox(height: 12),

            /// ITEM COUNT
            Text(
              '${order.items?.length ?? 0} món (${order.items?.fold<int>(0, (sum, item) => sum + (item.quantity ?? 0)) ?? 0} cái)',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            /// TOTAL
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng cộng',
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  AppFormatters.formatCurrency(
                      order.totalAmount ?? 0),
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Format địa chỉ an toàn (FIX lỗi address)
  String _formatAddress(dynamic address) {
    if (address == null) return 'Không xác định';

    try {
      final street = address.street ?? '';
      final ward = address.ward ?? '';
      final city = address.city ?? '';

      return [street, ward, city]
          .where((e) => e.isNotEmpty)
          .join(', ');
    } catch (e) {
      return 'Không xác định';
    }
  }
}