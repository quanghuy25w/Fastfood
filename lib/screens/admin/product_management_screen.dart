import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/api_service.dart';
import 'product_form_screen.dart';
import 'product_detail_screen.dart';
import 'widgets/product_grid_card_widget.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  late Future<List<Product>> _future;
  String _searchQuery = '';

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

  Future<void> _openDetail(Product product) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
    if (changed == true && mounted) {
      await _refresh();
    }
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_searchQuery.isEmpty) return products;
    return products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()) || p.category.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Sản phẩm'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search action
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4F46E5),
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF4F46E5),
        child: FutureBuilder<List<Product>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFF4F46E5),
                ),
              );
            }

            final allProducts = snap.data ?? <Product>[];
            final filteredProducts = _filterProducts(allProducts);

            if (filteredProducts.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: isDark ? Colors.grey[700] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có sản phẩm',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy thêm sản phẩm đầu tiên',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return CustomScrollView(
              slivers: [
                /// ===== SEARCH BAR =====
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      onChanged: (query) {
                        setState(() => _searchQuery = query);
                      },
                      decoration: InputDecoration(
                        hintText: 'Tìm sản phẩm...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                /// ===== GRID LAYOUT (2 COLUMNS) =====
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filteredProducts[index];
                        return InkWell(
                          onTap: () => _openDetail(product),
                          child: ProductGridCardWidget(
                            product: product,
                            onEdit: () => _openForm(product),
                            onDelete: () => _confirmDelete(product),
                          ),
                        );
                      },
                      childCount: filteredProducts.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
