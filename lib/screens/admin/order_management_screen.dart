// lib/screens/admin/order_management_screen.dart

import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../services/database_service.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  late Future<List<Order>> _allOrdersFuture;

  @override
  void initState() {
    super.initState();
    _allOrdersFuture = _loadAllOrders();
  }

  Future<List<Order>> _loadAllOrders() async {
    final db = await DatabaseService.instance.database;
    final ordersRows = await db.query('orders', orderBy: 'id DESC');

    final result = <Order>[];
    for (final o in ordersRows) {
      final rows = await db.rawQuery('''
        SELECT
          oi.quantity,
          oi.price,
          oi.product_name,
          COALESCE(p.id, oi.product_id) AS product_id,
          COALESCE(p.name, oi.product_name) AS product_name_fallback,
          COALESCE(p.description, '') AS description,
          COALESCE(p.image_url, 'https://picsum.photos/seed/deleted/400/300') AS image_url,
          COALESCE(p.category, 'Đã xóa') AS category
        FROM order_items oi
        LEFT JOIN products p ON p.id = oi.product_id
        WHERE oi.order_id = ?
      ''', [o['id']]);

      final items = rows
          .map(
            (r) => OrderItem(
              product: Product(
                id: r['product_id'] as int,
                name: (r['product_name_fallback'] as String).isEmpty
                    ? r['product_name'] as String
                    : r['product_name_fallback'] as String,
                description: r['description'] as String,
                imageUrl: r['image_url'] as String,
                category: r['category'] as String,
                price: (r['price'] as num).toDouble(),
                isFeatured: false,
              ),
              quantity: r['quantity'] as int,
            ),
          )
          .toList();

      result.add(
        Order(
          id: o['id'] as int,
          userId: o['user_id'] as int,
          items: items,
          totalAmount: (o['total_amount'] as num).toDouble(),
          status: o['status'] as String,
          paymentStatus: o['payment_status'] as String,
          address: o['address'] as String,
          paymentMethod: o['payment_method'] as String,
          storeNote: (o['store_note'] as String?)?.trim() ?? '',
          createdAt: DateTime.parse(o['created_at'] as String),
        ),
      );
    }
    return result;
  }

  Future<void> _refresh() async {
    setState(() => _allOrdersFuture = _loadAllOrders());
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      'orders',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [order.id],
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Đơn hàng'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF4F46E5),
        child: FutureBuilder<List<Order>>(
          future: _allOrdersFuture,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4F46E5),
                ),
              );
            }

            final orders = snap.data ?? [];

            if (orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: isDark ? Colors.grey[700] : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có đơn hàng',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderCard(
                  order: order,
                  onStatusChange: (newStatus) =>
                      _updateOrderStatus(order, newStatus),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// ==================
/// ORDER CARD
/// ==================
class OrderCard extends StatefulWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onStatusChange,
  });

  final Order order;
  final Function(String) onStatusChange;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  late String _selectedStatus;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFA500); // Orange
      case 'confirmed':
      case 'processing':
        return const Color(0xFF2196F3); // Blue
      case 'completed':
        return const Color(0xFF22C55E); // Green
      case 'cancelled':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'processing':
        return 'Đang xử lý';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String _getPaymentLabel(String payment) {
    switch (payment) {
      case 'pending':
        return 'Chưa thanh toán';
      case 'paid':
        return 'Đã thanh toán';
      case 'failed':
        return 'Thanh toán thất bại';
      default:
        return payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(_selectedStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          /// ===== HEADER ROW =====
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đơn #${widget.order.id}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(widget.order.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                /// Status Badge (Pill style)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _getStatusLabel(_selectedStatus),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),

          /// ===== SUMMARY ROW (Price & Payment) =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Total Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng tiền',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(widget.order.totalAmount),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22C55E),
                            fontSize: 18,
                          ),
                    ),
                  ],
                ),

                /// Payment Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Thanh toán',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPaymentLabel(widget.order.paymentStatus),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: widget.order.paymentStatus == 'paid'
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFFFA500),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// ===== VIEW DETAILS BUTTON =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF4F46E5).withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF4F46E5).withOpacity(0.05),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isExpanded ? 'Ẩn chi tiết' : 'Xem chi tiết',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF4F46E5),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: const Color(0xFF4F46E5),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// ===== EXPANDED DETAILS =====
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: isDark ? Colors.grey[800] : Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Items List
                  ...widget.order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isDark ? Colors.grey[800] : Colors.grey[300],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                item.product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.image_not_supported,
                                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.quantity}x · ${_formatPrice(item.product.price)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatPrice(item.product.price * item.quantity),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                  ),
                  const SizedBox(height: 12),

                  /// Address
                  Text(
                    'Địa chỉ giao hàng',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.order.address,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                  ),

                  const SizedBox(height: 12),

                  /// Payment Method
                  Text(
                    'Phương thức thanh toán',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.order.paymentMethod == 'COD'
                        ? 'Thanh toán khi nhận hàng'
                        : widget.order.paymentMethod,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                  ),

                  if (widget.order.storeNote.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Ghi chú cửa hàng',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.order.storeNote,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          /// ===== STATUS UPDATE DROPDOWN =====
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Cập nhật trạng thái',
                labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              items: [
                'pending',
                'confirmed',
                'processing',
                'completed',
                'cancelled',
              ]
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusLabel(status)),
                      ))
                  .toList(),
              onChanged: (newStatus) {
                if (newStatus != null && newStatus != _selectedStatus) {
                  setState(() => _selectedStatus = newStatus);
                  widget.onStatusChange(newStatus);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật trạng thái thành công'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ==================
/// HELPERS
/// ==================
String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}

String _formatPrice(double price) {
  if (price >= 1000000) {
    return '${(price / 1000000).toStringAsFixed(1)}M₫';
  } else if (price >= 1000) {
    return '${(price / 1000).toStringAsFixed(1)}K₫';
  }
  return '${price.toStringAsFixed(0)}₫';
}
