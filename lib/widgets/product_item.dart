import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/models/product_model.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key, required this.product, this.onTap, this.onAdd});

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final image = product.image?.trim() ?? '';
    final hasNetworkImage =
        image.startsWith('http://') || image.startsWith('https://');
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: 1.2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section (60% of height)
            Expanded(
              flex: 60,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: colors.secondaryContainer),
                child: Stack(
                  children: [
                    hasNetworkImage
                        ? Image.network(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _PlaceholderImage(colors: colors);
                            },
                          )
                        : _PlaceholderImage(colors: colors),
                  ],
                ),
              ),
            ),
            // Content section (40% of height)
            Expanded(
              flex: 40,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name and category
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          if (product.categoryId != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Danh mục ${product.categoryId}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Price and add button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            AppFormatters.formatCurrency(product.price),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onAdd,
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SizedBox(
                                width: 38,
                                height: 38,
                                child: Icon(
                                  Icons.add,
                                  color: colors.onPrimary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage({required this.colors});

  final AppColorPalette colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(Icons.fastfood_rounded, size: 42, color: colors.iconAccent),
    );
  }
}
