import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../data/models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key, required this.product});

  final Product product;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageController;
  late final TextEditingController _categoryIdController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;

    _nameController = TextEditingController(text: product.name);
    _priceController = TextEditingController(text: product.price.toString());
    _descriptionController = TextEditingController(
      text: product.description ?? '',
    );
    _imageController = TextEditingController(text: product.image ?? '');
    _categoryIdController = TextEditingController(
      text: product.categoryId?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _categoryIdController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final productProvider = context.read<ProductProvider>();

    setState(() {
      _isSaving = true;
    });

    final updatedProduct = Product(
      id: widget.product.id,
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
      createdAt: widget.product.createdAt,
    );

    await productProvider.updateProduct(updatedProduct);
    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    final errorMessage = productProvider.errorMessage;
    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cập nhật sản phẩm thành công')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sửa sản phẩm')),
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
                text: 'Cap nhat',
                onPressed: _saveChanges,
                isLoading: _isSaving,
                fullWidth: true,
                leadingIcon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
