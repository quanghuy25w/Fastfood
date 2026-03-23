import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_readability_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = context.read<AuthProvider>().user;
      if (u != null) {
        context.read<CartProvider>().load(u.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onSwitchToCart: () => setState(() => _index = 1),
            onSwitchToProfile: () => setState(() => _index = 2),
          ),
          CartScreen(
            onSwitchToHome: () => setState(() => _index = 0),
            onSwitchToProfile: () => setState(() => _index = 2),
          ),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// Floating bottom navigation bar — Material 3, rounded, shadowed.
class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: Icons.home_outlined, iconSelected: Icons.home_rounded, label: 'Trang chủ'),
    (icon: Icons.shopping_cart_outlined, iconSelected: Icons.shopping_cart_rounded, label: 'Giỏ hàng'),
    (icon: Icons.person_outline, iconSelected: Icons.person_rounded, label: 'Tôi'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).padding.bottom;
    const primary = AppReadabilityTheme.primary;

    /// True Dark: nền #1E1E1E; accent #FF8A65 chỉ cho tab "Tôi" khi đang chọn.
    final barColor = isDark ? AppReadabilityTheme.darkSurface : cs.surface;
    final muted = isDark ? AppReadabilityTheme.darkOnSurfaceVariant : cs.onSurfaceVariant;

    Color itemColor(int i, bool selected) {
      if (!isDark) {
        return selected ? primary : muted;
      }
      if (selected && i == 2) return AppReadabilityTheme.darkAccent;
      if (selected) return AppReadabilityTheme.darkOnSurface;
      return muted;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom + 16),
      child: Container(
        decoration: BoxDecoration(
          color: barColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.45 : 0.05),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final selected = currentIndex == i;
                final fg = itemColor(i, selected);
                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            selected ? item.iconSelected : item.icon,
                            size: 24,
                            color: fg,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              color: fg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
