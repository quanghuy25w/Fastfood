import 'package:flutter/material.dart';

class ProductFormValue {
  const ProductFormValue({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  final String name;
  final double price;
  final String imageUrl;
  final String description;
}

class ProductFormWidget extends StatefulWidget {
  const ProductFormWidget({
    super.key,
    this.initialName = '',
    this.initialPrice,
    this.initialImageUrl = '',
    this.initialDescription = '',
    this.loading = false,
    required this.onSubmit,
  });

  final String initialName;
  final double? initialPrice;
  final String initialImageUrl;
  final String initialDescription;
  final bool loading;
  final ValueChanged<ProductFormValue> onSubmit;

  @override
  State<ProductFormWidget> createState() => _ProductFormWidgetState();
}

class _ProductFormWidgetState extends State<ProductFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _imageUrl;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _price = TextEditingController(
      text: widget.initialPrice == null ? '' : widget.initialPrice!.toStringAsFixed(0),
    );
    _imageUrl = TextEditingController(text: widget.initialImageUrl);
    _description = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _imageUrl.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FieldLabel('Tên sản phẩm'),
              TextFormField(
                controller: _name,
                validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập tên sản phẩm' : null,
                decoration: const InputDecoration(hintText: 'Ví dụ: Cơm gà xối mỡ'),
              ),
              const SizedBox(height: 12),
              _FieldLabel('Giá'),
              TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Vui lòng nhập giá';
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed <= 0) return 'Giá không hợp lệ';
                  return null;
                },
                decoration: const InputDecoration(hintText: 'Ví dụ: 45000'),
              ),
              const SizedBox(height: 12),
              _FieldLabel('Image URL'),
              TextFormField(
                controller: _imageUrl,
                validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập link ảnh' : null,
                decoration: const InputDecoration(hintText: 'https://...'),
              ),
              const SizedBox(height: 12),
              _FieldLabel('Mô tả'),
              TextFormField(
                controller: _description,
                minLines: 3,
                maxLines: 5,
                validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập mô tả' : null,
                decoration: const InputDecoration(hintText: 'Mô tả ngắn về sản phẩm'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: widget.loading
                    ? null
                    : () {
                        if (!_formKey.currentState!.validate()) return;
                        widget.onSubmit(
                          ProductFormValue(
                            name: _name.text.trim(),
                            price: double.parse(_price.text.trim()),
                            imageUrl: _imageUrl.text.trim(),
                            description: _description.text.trim(),
                          ),
                        );
                      },
                child: widget.loading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onPrimary,
                        ),
                      )
                    : const Text('Lưu sản phẩm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
