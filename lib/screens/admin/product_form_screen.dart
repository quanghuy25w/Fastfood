import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/api_service.dart';
import 'widgets/product_form_widget.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  bool get isEdit => product != null;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  bool _loading = false;

  Future<void> _save(ProductFormValue value) async {
    setState(() => _loading = true);
    try {
      if (widget.isEdit) {
        final p = widget.product!;
        await ApiService.instance.updateProduct(
          id: p.id,
          name: value.name,
          description: value.description,
          imageUrl: value.imageUrl,
          price: value.price,
          category: p.category,
          isActive: true,
          isFeatured: p.isFeatured,
          isFavorite: p.isFavorite,
        );
      } else {
        await ApiService.instance.createProduct(
          name: value.name,
          description: value.description,
          imageUrl: value.imageUrl,
          price: value.price,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          widget.isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: IconThemeData(color: cs.primary),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ProductFormWidget(
              loading: _loading,
              initialName: widget.product?.name ?? '',
              initialPrice: widget.product?.price,
              initialImageUrl: widget.product?.imageUrl ?? '',
              initialDescription: widget.product?.description ?? '',
              initialCategory: widget.product?.category ?? '',
              onSubmit: _save,
            ),
          ),
        ),
      ),
    );
  }
}
