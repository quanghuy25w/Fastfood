import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class ProductFormValue {
  const ProductFormValue({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.category,
  });

  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final String category;
}

class ProductFormWidget extends StatefulWidget {
  const ProductFormWidget({
    super.key,
    this.initialName = '',
    this.initialPrice,
    this.initialImageUrl = '',
    this.initialDescription = '',
    this.initialCategory = '',
    this.loading = false,
    required this.onSubmit,
  });

  final String initialName;
  final double? initialPrice;
  final String initialImageUrl;
  final String initialDescription;
  final String initialCategory;
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

  // ✅ category value
  String? _category;

  // ✅ category list từ API
  List<String> _categories = [];
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(text: widget.initialName);

    _price = TextEditingController(
      text: widget.initialPrice == null
          ? ''
          : widget.initialPrice!.toStringAsFixed(0),
    );

    _imageUrl = TextEditingController(text: widget.initialImageUrl);
    _description = TextEditingController(text: widget.initialDescription);

    _category =
        widget.initialCategory.isEmpty ? null : widget.initialCategory;

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await ApiService.instance.getCategories();
      setState(() {
        _categories = data;
        _loadingCategories = false;
      });
    } catch (e) {
      setState(() => _loadingCategories = false);
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 0 : 2,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: cs.outlineVariant, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== IMAGE PREVIEW =====
              if (_imageUrl.text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _imageUrl.text.trim(),
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => Container(
                        height: 160,
                        color: isDark ? Colors.grey[900] : Colors.grey[200],
                        child: const Center(child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey)),
                      ),
                    ),
                  ),
                ),

              // ===== NAME =====
              _FieldLabel('Tên sản phẩm'),
              TextFormField(
                controller: _name,
                validator: (v) => v == null || v.trim().isEmpty ? 'Chưa nhập tên sản phẩm' : null,
                decoration: InputDecoration(
                  hintText: '',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF23232B) : const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 14),

              // ===== PRICE =====
              _FieldLabel('Giá'),
              TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Chưa nhập giá';
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed <= 0) return 'Giá không hợp lệ';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: '',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF23232B) : const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 14),

              // ===== CATEGORY =====
              _FieldLabel('Danh mục'),
              _loadingCategories
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : DropdownButtonFormField<String>(
                      value: _category,
                      items: _categories.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (v) => setState(() => _category = v),
                      validator: (v) => v == null ? 'Vui lòng chọn danh mục' : null,
                      decoration: InputDecoration(
                        hintText: 'Chọn danh mục',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF23232B) : const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),

              const SizedBox(height: 14),

              // ===== IMAGE =====
              _FieldLabel('Image URL'),
              TextFormField(
                controller: _imageUrl,
                onChanged: (_) => setState(() {}),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nhập đường dẫn ảnh' : null,
                decoration: InputDecoration(
                  hintText: 'https://...',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF23232B) : const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 14),

              // ===== DESCRIPTION =====
              _FieldLabel('Mô tả'),
              TextFormField(
                controller: _description,
                minLines: 3,
                maxLines: 5,
                validator: (v) => v == null || v.trim().isEmpty ? 'Nhập mô tả sản phẩm' : null,
                decoration: InputDecoration(
                  hintText: 'Mô tả sản phẩm',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF23232B) : const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 22),

              // ===== BUTTON =====
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
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
                              category: _category!,
                            ),
                          );
                        },
                  child: widget.loading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: cs.onPrimary,
                          ),
                        )
                      : const Text('Lưu sản phẩm'),
                ),
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
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}