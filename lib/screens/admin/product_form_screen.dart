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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProductFormWidget(
            loading: _loading,
            initialName: widget.product?.name ?? '',
            initialPrice: widget.product?.price,
            initialImageUrl: widget.product?.imageUrl ?? '',
            initialDescription: widget.product?.description ?? '',
            onSubmit: _save,
          ),
        ],
      ),
    );
  }
}
