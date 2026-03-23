import 'package:flutter/material.dart';

/// Thanh tìm kiếm hiện đại — bo góc, shadow nhẹ.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.hint = 'Tìm kiếm...',
    this.onTap,
  });

  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: cs.onSurfaceVariant.withOpacity(0.9),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 22,
            color: cs.onSurfaceVariant.withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
