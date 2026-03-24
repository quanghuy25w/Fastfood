// lib/screens/product/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    // SỬ DỤNG TRỰC TIẾP TỪ THEME ĐỂ ĐỒNG BỘ 100%
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final text = theme.textTheme;

    final money = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return Scaffold(
      // Sử dụng surface thay vì fix mã màu để khớp với phần còn lại của App
      backgroundColor: cs.surface, 
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Chi tiết sản phẩm',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        // Bo góc AppBar mượt mà hơn
        shape: Border(
          bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.3), width: 1),
        ),
        iconTheme: IconThemeData(color: cs.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ===== CARD CHI TIẾT =====
          Card(
            elevation: 0,
            // Sử dụng surfaceContainer hoặc surfaceVariant để tạo chiều sâu trong Dark Mode
            color: isDark ? cs.surfaceContainerHigh : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: cs.outlineVariant.withOpacity(0.5), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ẢNH SẢN PHẨM
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      // Màu nền ảnh nhẹ nhàng hơn
                      color: isDark ? cs.surfaceContainerLowest : Colors.grey[50],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        product.imageUrl,
                        height: 280,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Padding(
                          padding: const EdgeInsets.all(40),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: cs.outline,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// TÊN SẢN PHẨM
                  Text(
                    product.name,
                    style: text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface, // Tự động trắng/đen theo Mode
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// DANH MỤC (CHIP)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withOpacity(isDark ? 0.3 : 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      product.category,
                      style: text.labelLarge?.copyWith(
                        color: isDark ? cs.primaryContainer : cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// GIÁ CẢ
                  Row(
                    children: [
                      Text(
                        'Giá niêm yết:',
                        style: text.titleMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        money.format(product.price),
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Divider(color: cs.outlineVariant.withOpacity(0.4)),
                  const SizedBox(height: 16),

                  /// MÔ TẢ
                  Text(
                    'Mô tả sản phẩm',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: text.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// NÚT THÊM VÀO GIỎ (Vẫn giữ Logic cũ)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: cs.primary.withOpacity(0.3),
                      ),
                      onPressed: () async {
                        await context.read<CartProvider>().addProduct(product);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Đã thêm vào giỏ hàng thành công!'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: isDark ? cs.primaryContainer : Colors.grey[900],
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 24),
                      label: const Text(
                        'MUA NGAY',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}