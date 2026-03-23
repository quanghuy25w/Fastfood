import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/address.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_readability_theme.dart';
import '../address/address_form_screen.dart';
import 'order_detail_screen.dart';
import 'orders_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      setState(() {
        _ordersFuture = ApiService.instance.getOrdersByUser(user.id);
      });
    } else {
      setState(() => _ordersFuture = Future.value(<Order>[]));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Chưa đăng nhập',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final addr = Address.fromJson(user.address);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppReadabilityTheme.darkAccent
            : AppReadabilityTheme.primary,
        onRefresh: () async {
          final u = context.read<AuthProvider>().user;
          if (u != null) {
            final next = ApiService.instance.getOrdersByUser(u.id);
            setState(() {
              _ordersFuture = next;
            });
            await next;
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          _ProfileHeader(user: user),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _QuickActionsCard(
                    onOrders: () => _navigateOrders(context, user.id),
                    onWallet: () => _showComingSoon(context),
                    onAddress: () => _openAddressForm(context, addr, user),
                    onSettings: () => _showSettings(context),
                  ),
                  const SizedBox(height: 24),
                  _OrderHistorySection(
                    userId: user.id,
                    ordersFuture: _ordersFuture,
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () => _logout(context),
                      icon: Icon(Icons.logout_outlined, size: 18, color: cs.outline),
                      label: Text(
                        'Đăng xuất',
                        style: TextStyle(color: cs.outline, fontWeight: FontWeight.w500),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        side: BorderSide(color: cs.outlineVariant),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  void _navigateOrders(BuildContext context, int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrdersListScreen(userId: userId)),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng đang phát triển')),
    );
  }

  Future<void> _openAddressForm(
    BuildContext context,
    Address? addr,
    dynamic user,
  ) async {
    final saved = await Navigator.push<Address>(
      context,
      MaterialPageRoute(
        builder: (_) => AddressFormScreen(
          initialAddress: addr,
          initialStreetFallback:
              addr == null && user.address.trim().isNotEmpty ? user.address : null,
        ),
      ),
    );
    if (saved != null && context.mounted) {
      await context.read<AuthProvider>().saveAddress(saved.toJson());
    }
  }

  void _showSettings(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Cài đặt', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(
                  theme.brightness == Brightness.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: theme.brightness == Brightness.dark
                      ? AppReadabilityTheme.darkAccent
                      : theme.colorScheme.primary,
                ),
                title: const Text('Giao diện sáng / tối'),
                trailing: Switch(
                  value: theme.brightness == Brightness.dark,
                  activeTrackColor: AppReadabilityTheme.darkAccent.withOpacity(0.5),
                  thumbColor: WidgetStateProperty.resolveWith((s) {
                    if (s.contains(WidgetState.selected)) {
                      return theme.brightness == Brightness.dark
                          ? AppReadabilityTheme.darkAccent
                          : theme.colorScheme.primary;
                    }
                    return null;
                  }),
                  onChanged: (_) {
                    context.read<ThemeProvider>().toggleLightDark();
                    Navigator.pop(ctx);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    context.read<CartProvider>().clearMemory();
    await context.read<AuthProvider>().logout();
  }
}

// ————— Header: Avatar + Tên + Email + Badge —————
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? AppReadabilityTheme.darkOnSurface : Colors.white;
    final emailColor = isDark ? AppReadabilityTheme.darkOnSurfaceVariant : Colors.white.withOpacity(0.92);
    final avatarBg = isDark ? AppReadabilityTheme.darkSurfaceElevated : Colors.white.withOpacity(0.3);
    final avatarBorder =
        isDark ? AppReadabilityTheme.darkAccent.withOpacity(0.45) : Colors.white.withOpacity(0.5);
    final avatarLetterColor = isDark ? AppReadabilityTheme.darkOnSurface : Colors.white;
    final badgeBg = isDark ? AppReadabilityTheme.darkAccent.withOpacity(0.22) : Colors.white.withOpacity(0.2);
    final badgeFg = isDark ? AppReadabilityTheme.darkAccent : Colors.white;

    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 24),
        decoration: BoxDecoration(
          color: isDark ? AppReadabilityTheme.darkSurface : null,
          gradient: isDark
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary,
                    cs.primary.withOpacity(0.85),
                  ],
                ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tài khoản',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Stack(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: avatarBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: avatarBorder, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: avatarLetterColor,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? AppReadabilityTheme.darkSurfaceElevated : cs.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.45 : 0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 16,
                        color: isDark ? AppReadabilityTheme.darkAccent : cs.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: emailColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Thành viên',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: badgeFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ————— Quick Actions: 4 ô icon + label —————
class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({
    required this.onOrders,
    required this.onWallet,
    required this.onAddress,
    required this.onSettings,
  });

  final VoidCallback onOrders;
  final VoidCallback onWallet;
  final VoidCallback onAddress;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppReadabilityTheme.darkSurface : AppReadabilityTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppReadabilityTheme.darkBorder : AppReadabilityTheme.subtleBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionItem(
              icon: Icons.receipt_long_outlined,
              label: 'Đơn hàng',
              onTap: onOrders,
            ),
          ),
          Expanded(
            child: _QuickActionItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Ví',
              onTap: onWallet,
            ),
          ),
          Expanded(
            child: _QuickActionItem(
              icon: Icons.location_on_outlined,
              label: 'Địa chỉ',
              onTap: onAddress,
            ),
          ),
          Expanded(
            child: _QuickActionItem(
              icon: Icons.settings_outlined,
              label: 'Cài đặt',
              onTap: onSettings,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final iconBg = isDark ? AppReadabilityTheme.darkSurfaceElevated : cs.primaryContainer.withOpacity(0.5);
    final iconFg = isDark ? AppReadabilityTheme.darkAccent : cs.primary;
    final labelColor = isDark ? AppReadabilityTheme.darkOnSurface : AppReadabilityTheme.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconFg, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ————— Order History Section —————
class _OrderHistorySection extends StatelessWidget {
  const _OrderHistorySection({
    required this.userId,
    required this.ordersFuture,
  });

  final int userId;
  final Future<List<Order>> ordersFuture;

  static final _money = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
  static final _df = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headingColor = isDark ? AppReadabilityTheme.darkOnSurface : AppReadabilityTheme.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Đơn hàng gần đây',
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: headingColor,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OrdersListScreen(userId: userId)),
                );
              },
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Order>>(
          future: ordersFuture,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                    color: isDark ? AppReadabilityTheme.darkAccent : theme.colorScheme.primary,
                  ),
                ),
              );
            }
            final orders = snap.data ?? [];
            if (orders.isEmpty) {
              return _OrderEmptyCard();
            }
            return Column(
              children: orders.take(3).map((o) => _OrderCard(
                order: o,
                moneyFormat: _money,
                dateFormat: _df,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OrderDetailScreen(order: o)),
                  );
                },
              )).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.moneyFormat,
    required this.dateFormat,
    required this.onTap,
  });

  final Order order;
  final NumberFormat moneyFormat;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  static String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Hoàn thành';
      case 'shipping':
        return 'Đang giao';
      case 'confirmed':
        return 'Đã xác nhận';
      default:
        return 'Chờ xử lý';
    }
  }

  static Color _statusColor(String status, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppReadabilityTheme.darkAccent;
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case 'completed':
        return const Color(0xFF81C784);
      case 'shipping':
      case 'confirmed':
        return isDark ? accent : cs.primary;
      default:
        return isDark ? accent : cs.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppReadabilityTheme.darkSurface : AppReadabilityTheme.cardSurface;
    final borderColor = isDark ? AppReadabilityTheme.darkBorder : AppReadabilityTheme.subtleBorder;
    final titleColor = isDark ? AppReadabilityTheme.darkOnSurface : AppReadabilityTheme.textPrimary;
    final metaColor =
        isDark ? AppReadabilityTheme.darkOnSurfaceVariant : cs.onSurfaceVariant;
    final priceColor = isDark ? AppReadabilityTheme.darkAccent : cs.primary;
    final iconBg = isDark ? AppReadabilityTheme.darkSurfaceElevated : cs.primaryContainer.withOpacity(0.5);
    final iconFg = isDark ? AppReadabilityTheme.darkAccent : cs.primary;
    final chevronColor = isDark ? AppReadabilityTheme.darkOnSurfaceVariant : cs.outline;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.receipt_long_outlined, color: iconFg, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đơn #${order.id}',
                        style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(order.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                              color: metaColor,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      moneyFormat.format(order.totalAmount),
                      style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: priceColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(order.status, context).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusLabel(order.status),
                        style: theme.textTheme.labelSmall?.copyWith(
                              color: _statusColor(order.status, context),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: chevronColor, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderEmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppReadabilityTheme.darkSurfaceElevated : cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppReadabilityTheme.darkBorder : cs.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: isDark ? AppReadabilityTheme.darkOnSurfaceVariant : cs.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có đơn hàng',
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppReadabilityTheme.darkOnSurfaceVariant : cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
