import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../data/models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();
  final _categoryIdController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _categoryIdController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    AppHelpers.dismissKeyboard(context);

    setState(() {
      _isSaving = true;
    });

    final product = Product(
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      image: _imageController.text.trim().isEmpty
          ? null
          : _imageController.text.trim(),
      categoryId: _categoryIdController.text.trim().isEmpty
          ? null
          : int.tryParse(_categoryIdController.text.trim()),
      createdAt: DateTime.now().toIso8601String(),
    );

    await context.read<ProductProvider>().addProduct(product);
    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    final errorMessage = context.read<ProductProvider>().errorMessage;
    if (errorMessage != null) {
      AppHelpers.showErrorSnackBar(context, errorMessage);
      return;
    }

    AppHelpers.showSuccessSnackBar(context, 'Them san pham thanh cong');
    AppHelpers.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Them san pham')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Tên sản phẩm',
                hintText: 'Nhập tên sản phẩm',
                prefixIcon: const Icon(Icons.fastfood_outlined),
                textInputAction: TextInputAction.next,
                validator: (value) => AppValidators.requiredField(
                  value,
                  fieldName: 'tên sản phẩm',
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _priceController,
                labelText: 'Gia',
                hintText: 'Nhap gia > 0',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.attach_money_outlined),
                validator: (value) =>
                    AppValidators.positiveNumber(value, fieldName: 'gia'),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Mo ta',
                hintText: 'Mo ta ngan ve san pham (tuy chon)',
                maxLines: 3,
                minLines: 3,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _imageController,
                labelText: 'Image URL',
                hintText: 'Duong dan hinh anh (tuy chon)',
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.image_outlined),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _categoryIdController,
                labelText: 'Category ID',
                hintText: 'Vi du: 1, 2, 3 (tuy chon)',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.category_outlined),
                validator: (value) =>
                    AppValidators.optionalInt(value, fieldName: 'category id'),
              ),
              const SizedBox(height: 20),
              CustomButton.primary(
                text: 'Luu san pham',
                onPressed: _saveProduct,
                isLoading: _isSaving,
                fullWidth: true,
                leadingIcon: const Icon(Icons.save_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
