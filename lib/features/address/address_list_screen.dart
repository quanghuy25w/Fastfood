import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/address_model.dart';
import '../../providers/address_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import 'add_address_screen.dart';

/// Hiển thị danh sách địa chỉ giao hàng của người dùng.
///
/// Cho phép chọn, thêm, sửa, xoá địa chỉ.
/// Kết nối AddressProvider để quản lý state và dữ liệu SQLite.
/// Tích hợp với Checkout flow để chọn địa chỉ giao hàng.
class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key, this.isCheckoutSelection = false});

  final bool isCheckoutSelection;

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  Future<void> _loadAddresses() async {
    await context.read<AddressProvider>().fetchAddresses();
  }

  Future<void> _openAddAddress() async {
    final createdAddress = await Navigator.of(context).push<Address>(
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );

    if (!mounted) {
      return;
    }

    if (createdAddress != null) {
      context.read<AddressProvider>().selectAddress(createdAddress);
    }
  }

  Future<void> _openEditAddress(Address address) async {
    final updatedAddress = await Navigator.of(context).push<Address>(
      MaterialPageRoute(
        builder: (_) => AddAddressScreen(initialAddress: address),
      ),
    );

    if (!mounted) {
      return;
    }

    if (updatedAddress != null) {
      context.read<AddressProvider>().selectAddress(updatedAddress);
    }
  }

  Future<void> _deleteAddress(Address address) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Xoá địa chỉ',
      message: 'Bạn có chắc chắn muốn xoá địa chỉ này?',
      confirmText: 'Xoá',
      cancelText: 'Huy',
      icon: Icons.delete_outline,
      isDestructive: true,
    );

    if (!confirmed || !mounted) {
      return;
    }

    final provider = context.read<AddressProvider>();
    await provider.deleteAddress(address.id);

    if (!mounted) {
      return;
    }

    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã xoá địa chỉ')));
  }

  void _selectAddress(Address address) {
    context.read<AddressProvider>().selectAddress(address);

    if (widget.isCheckoutSelection) {
      Navigator.of(context).pop(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();
    final addresses = provider.addresses;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCheckoutSelection
              ? 'Chọn địa chỉ giao hàng'
              : 'Danh sách địa chỉ',
        ),
      ),
      body: _buildBody(provider, addresses),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: CustomButton.primary(
            text: '+ Thêm địa chỉ',
            onPressed: _openAddAddress,
            fullWidth: true,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AddressProvider provider, List<Address> addresses) {
    final colors = AppColors.of(context);

    if (provider.isLoading && addresses.isEmpty) {
      return const LoadingWidget.medium(message: 'Đang tải địa chỉ...');
    }

    if (provider.errorMessage != null && addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(provider.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              CustomButton.secondary(
                text: 'Thử lại',
                onPressed: _loadAddresses,
                leadingIcon: const Icon(Icons.refresh),
                width: 150,
              ),
            ],
          ),
        ),
      );
    }

    if (addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 48,
                color: colors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                'Chưa có địa chỉ giao hàng',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Thêm địa chỉ để việc đặt món nhanh hơn',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final selectedId = provider.selectedAddress?.id;

    return RefreshIndicator(
      onRefresh: _loadAddresses,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: addresses.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final address = addresses[index];
          final isSelected = address.id == selectedId;

          return _AddressItem(
            address: address,
            isSelected: isSelected,
            onTap: () => _selectAddress(address),
            onEdit: () => _openEditAddress(address),
            onDelete: () => _deleteAddress(address),
          );
        },
      ),
    );
  }
}

class _AddressItem extends StatelessWidget {
  const _AddressItem({
    required this.address,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Address address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Material(
      color: isSelected
          ? colors.primaryContainer.withValues(alpha: 0.55)
          : colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colors.primary : colors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      address.recipientName.trim().isEmpty
                          ? 'Nguoi nhan'
                          : address.recipientName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: colors.primary),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                AppFormatters.formatPhone(
                  address.phone,
                  fallback: 'Chúa cập nhật số điện thoại',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                address.fullAddress,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (address.label != null &&
                  address.label!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Chip(
                  label: Text(address.label!.trim()),
                  visualDensity: VisualDensity.compact,
                ),
              ],
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    tooltip: 'Sua dia chi',
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    tooltip: 'Xoa dia chi',
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
