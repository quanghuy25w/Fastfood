import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/api_service.dart';
import 'product_form_screen.dart';
import 'widgets/product_card_widget.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getAdminProducts();
  }

  Future<void> _refresh() async {
    final next = ApiService.instance.getAdminProducts();
    setState(() => _future = next);
    await next;
  }

  Future<void> _openForm([Product? product]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
    if (saved == true && mounted) {
      await _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(product == null ? 'Thêm sản phẩm thành công' : 'Cập nhật sản phẩm thành công'),
        ),
      );
    }
  }

  Future<void> _confirmDelete(Product product) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa sản phẩm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ApiService.instance.deleteProduct(product.id);
    if (!mounted) return;
    await _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Xóa sản phẩm thành công')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
      body: RefreshIndicator(
        color: cs.primary,
        onRefresh: _refresh,
        child: FutureBuilder<List<Product>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator(color: cs.primary));
            }
            final list = snap.data ?? <Product>[];
            if (list.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 58, color: cs.outline),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có sản phẩm',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final p = list[i];
                return ProductCardWidget(
                  product: p,
                  onEdit: () => _openForm(p),
                  onDelete: () => _confirmDelete(p),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
