import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await ConfirmDialog.show(
      context,
      title: 'Dang xuat',
      message: 'Bạn có chắc chắn muốn đăng xuất không?',
      confirmText: 'Dang xuat',
      cancelText: 'Huy',
      icon: Icons.logout,
      onConfirm: () async {
        context.read<AuthProvider>().logout();
        return true;
      },
    );

    if (!shouldLogout || !context.mounted) {
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final username =
        authProvider.currentUser?.name ??
        authProvider.currentUser?.email ??
        'User';

    final tabs = [
      _HomeTab(username: username),
      const _CartQuickTab(),
      _ProfileTab(onLogout: () => _confirmLogout(context)),
    ];

    final titles = ['FastFood', 'Gio hang', 'Tai khoan'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.orderHistory);
              },
              icon: const Icon(Icons.receipt_long_outlined),
              tooltip: 'Lich su don hang',
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: tabs[_currentIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [colors.primary, colors.primary.withValues(alpha: 0.86)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chao, $username',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dat mon nhanh trong 1-2 thao tac',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.secondary,
                child: Icon(Icons.fastfood_rounded, color: colors.onSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _QuickTile(
          title: 'Kham pha menu',
          subtitle: 'Burger, pizza, ga ran, nuoc uong',
          icon: Icons.restaurant_menu,
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.productList);
          },
        ),
        _QuickTile(
          title: 'Gio hang',
          subtitle: 'Xem và cập nhật món đã chọn',
          icon: Icons.shopping_cart_checkout,
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.cart);
          },
        ),
        _QuickTile(
          title: 'Lich su don hang',
          subtitle: 'Theo doi cac don da dat',
          icon: Icons.receipt_long,
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.orderHistory);
          },
        ),
        _QuickTile(
          title: 'Cai dat',
          subtitle: 'Chủ đề và địa chỉ giao hàng',
          icon: Icons.settings_outlined,
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.settings);
          },
        ),
      ],
    );
  }
}

class _CartQuickTab extends StatelessWidget {
  const _CartQuickTab();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final cartProvider = context.watch<CartProvider>();
    final items = cartProvider.items;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.remove_shopping_cart_outlined,
                size: 50,
                color: colors.textSecondary,
              ),
              const SizedBox(height: 10),
              Text(
                'Chua co mon trong gio',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              CustomButton.primary(
                text: 'Dat mon ngay',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.productList);
                },
                width: 180,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Tong tien tam tinh',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  AppFormatters.formatCurrency(cartProvider.totalPrice),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...items.take(4).map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colors.secondaryContainer,
                  child: Icon(Icons.fastfood_rounded, color: colors.iconAccent),
                ),
                title: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('SL ${item.quantity}'),
                trailing: Text(AppFormatters.formatCurrency(item.subtotal)),
              ),
            ),
          );
        }),
        if (items.length > 4)
          Text(
            '+ ${items.length - 4} mon khac',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 12),
        CustomButton.primary(
          text: 'Mo gio hang day du',
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.cart);
          },
          fullWidth: true,
          trailingIcon: const Icon(Icons.arrow_forward_rounded),
        ),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  child: Icon(Icons.person_outline, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Nguoi dung',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '-',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _QuickTile(
          title: 'Quản lý địa chỉ',
          subtitle: 'Thêm, sửa, chọn địa chỉ giao hàng',
          icon: Icons.location_on_outlined,
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.settings);
          },
        ),
        _QuickTile(
          title: 'Cai dat giao dien',
          subtitle: 'Light mode / Dark mode',
          icon: Icons.dark_mode_outlined,
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.settings);
          },
        ),
        const SizedBox(height: 18),
        CustomButton.outline(
          text: 'Dang xuat',
          onPressed: onLogout,
          fullWidth: true,
          leadingIcon: const Icon(Icons.logout),
        ),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: colors.secondaryContainer,
            child: Icon(icon, color: colors.primary),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
