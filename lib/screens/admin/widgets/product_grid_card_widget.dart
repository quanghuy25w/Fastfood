// lib/screens/admin/widgets/product_grid_card_widget.dart

import 'package:flutter/material.dart';

import '../../../models/product.dart';

class ProductGridCardWidget extends StatefulWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductGridCardWidget({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ProductGridCardWidget> createState() => _ProductGridCardWidgetState();
}

class _ProductGridCardWidgetState extends State<ProductGridCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== PRODUCT IMAGE =====
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                color: isDark ? Colors.grey[800] : Colors.grey[300],
              ),
              child: widget.product.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 140,
                        cacheHeight: 200,
                        cacheWidth: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[300],
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey[600],
                                size: 40,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[300],
                            child: Center(
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFF4F46E5).withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[600],
                        size: 40,
                      ),
                    ),
            ),

            /// ===== PRODUCT INFO =====
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Product Name (max 2 lines)
                    Text(
                      widget.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                    ),

                    const Spacer(),

                    /// Price (Green #22C55E)
                    Text(
                      '${widget.product.price.toStringAsFixed(0)}₫',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22C55E),
                          ),
                    ),

                    const SizedBox(height: 6),

                    /// Action Buttons (Edit & Delete)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        /// Edit Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.onEdit,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.edit_outlined,
                                color: const Color(0xFF4F46E5),
                                size: 18,
                              ),
                            ),
                          ),
                        ),

                        /// Delete Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.onDelete,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.red[400],
                                size: 18,
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
