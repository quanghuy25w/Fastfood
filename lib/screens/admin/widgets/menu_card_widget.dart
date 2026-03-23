// lib/screens/admin/widgets/menu_card_widget.dart

import 'package:flutter/material.dart';

class MenuCardWidget extends StatefulWidget {
  const MenuCardWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<MenuCardWidget> createState() => _MenuCardWidgetState();
}

class _MenuCardWidgetState extends State<MenuCardWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed 
                    ? cs.primary.withOpacity(0.15) 
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isPressed ? 12 : 6,
                offset: Offset(0, _isPressed ? 6 : 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, size: 32, color: cs.primary),
                ),

                const SizedBox(height: 16),

                /// Label
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
