import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/models/product_model.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({
    super.key,
    required this.product,
    this.onTap,
    this.onAdd,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final image = product.image?.trim() ?? '';
    final hasNetworkImage =
        image.startsWith('http://') || image.startsWith('https://');

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                ),
                child: hasNetworkImage
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _PlaceholderImage(colors: colors);
                        },
                      )
                    : _PlaceholderImage(colors: colors),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    if (product.categoryId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Category ${product.categoryId}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    else
                      const SizedBox(height: 18),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppFormatters.formatCurrency(product.price),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: colors.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onAdd,
                            child: SizedBox(
                              width: 34,
                              height: 34,
                              child: Icon(
                                Icons.add,
                                color: colors.onPrimary,
                                size: 20,
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
      child: Icon(
        Icons.fastfood_rounded,
        size: 42,
        color: colors.iconAccent,
      ),
    );
  }
}
