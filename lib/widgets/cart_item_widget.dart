import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/models/cart_item_model.dart';

class CartItemWidget extends StatelessWidget {
  const CartItemWidget({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDelete,
  });

  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final image = item.image?.trim() ?? '';
    final hasNetworkImage =
        image.startsWith('http://') || image.startsWith('https://');

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasNetworkImage
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.fastfood, color: colors.iconAccent);
                      },
                    )
                  : Icon(Icons.fastfood, color: colors.iconAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppFormatters.formatCurrency(item.price),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.formatCurrency(item.subtotal),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                _QtyButton(
                  icon: Icons.add,
                  onTap: onIncrease,
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '${item.quantity}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                _QtyButton(
                  icon: Icons.remove,
                  onTap: onDecrease,
                  backgroundColor: colors.secondaryContainer,
                  foregroundColor: colors.textPrimary,
                ),
                const SizedBox(height: 6),
                _QtyButton(
                  icon: Icons.delete_outline,
                  onTap: onDelete,
                  backgroundColor: colors.error.withValues(alpha: 0.12),
                  foregroundColor: colors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon, size: 18, color: foregroundColor),
        ),
      ),
    );
  }
}
