import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

/// Header với greeting + avatar — dùng cho Home, Cart, Orders.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.subtitle,
    this.onAvatarTap,
  });

  final String subtitle;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ${user?.name ?? 'Bạn'}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        letterSpacing: -0.3,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: cs.primary.withOpacity(0.12),
              child: Text(
                (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
