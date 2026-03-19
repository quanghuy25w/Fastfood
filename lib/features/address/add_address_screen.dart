import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../data/models/address_model.dart';
import '../../providers/address_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_widget.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({
    super.key,
    this.initialAddress,
    this.autoSelectAfterSave = true,
  });

  final Address? initialAddress;
  final bool autoSelectAfterSave;

  bool get isEditMode => initialAddress != null;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final initial = widget.initialAddress;
    if (initial != null) {
      _recipientController.text = initial.recipientName;
      _phoneController.text = initial.phone;
      _labelController.text = initial.label ?? '';
      _addressController.text = initial.fullAddress;
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _phoneController.dispose();
    _labelController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<AddressProvider>();
    final label = _normalizeOptional(_labelController.text);

    Address? savedAddress;

    if (widget.isEditMode) {
      final current = widget.initialAddress!;
      final updatedAddress = current.copyWith(
        recipientName: _recipientController.text.trim(),
        phone: _phoneController.text.trim(),
        fullAddress: _addressController.text.trim(),
        label: label,
        clearLabel: label == null,
      );

      final isUpdated = await provider.updateAddress(updatedAddress);
      if (isUpdated) {
        savedAddress = updatedAddress;
      }
    } else {
      savedAddress = await provider.addAddress(
        Address(
          id: 0,
          recipientName: _recipientController.text.trim(),
          phone: _phoneController.text.trim(),
          label: label,
          fullAddress: _addressController.text.trim(),
        ),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
      return;
    }

    if (savedAddress != null && widget.autoSelectAfterSave) {
      provider.selectAddress(savedAddress);
    }

    final successMessage = widget.isEditMode
        ? 'Cap nhat dia chi thanh cong'
        : 'Them dia chi thanh cong';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(successMessage)));

    Navigator.of(context).pop(savedAddress);
  }

  String? _normalizeOptional(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();
    final isBusy = _isSubmitting || addressProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Sua dia chi' : 'Them dia chi'),
      ),
      body: LoadingOverlay(
        isLoading: isBusy,
        message: widget.isEditMode
            ? 'Dang cap nhat dia chi...'
            : 'Dang luu dia chi...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _recipientController,
                  labelText: 'Ten nguoi nhan',
                  hintText: 'Vi du: Nguyen Van A',
                  prefixIcon: const Icon(Icons.person_outline),
                  textInputAction: TextInputAction.next,
                  validator: (value) => AppValidators.requiredField(
                    value,
                    fieldName: 'ten nguoi nhan',
                  ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'So dien thoai',
                  hintText: 'Vi du: 0901234567',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: AppValidators.phone,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _labelController,
                  labelText: 'Nhan dia chi (tuy chon)',
                  hintText: 'Vi du: Nha rieng, Cong ty',
                  prefixIcon: const Icon(Icons.label_outline),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _addressController,
                  labelText: 'Dia chi chi tiet',
                  hintText: 'Nhap dia chi giao hang',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  maxLines: 3,
                  minLines: 3,
                  validator: (value) => AppValidators.requiredField(
                    value,
                    fieldName: 'dia chi chi tiet',
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton.primary(
                  text: widget.isEditMode ? 'Cap nhat dia chi' : 'Luu dia chi',
                  onPressed: _saveAddress,
                  enabled: !isBusy,
                  fullWidth: true,
                  leadingIcon: Icon(
                    widget.isEditMode
                        ? Icons.save_as_outlined
                        : Icons.save_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
