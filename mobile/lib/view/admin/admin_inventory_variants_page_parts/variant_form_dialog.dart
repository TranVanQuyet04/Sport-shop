part of '../admin_inventory_variants_page.dart';

class _VariantFormDialog extends StatefulWidget {
  const _VariantFormDialog({this.variant});

  final ProductVariantModel? variant;

  @override
  State<_VariantFormDialog> createState() => _VariantFormDialogState();
}

class _VariantFormDialogState extends State<_VariantFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _skuController = TextEditingController(
    text: widget.variant?.sku ?? '',
  );
  late final TextEditingController _sizeController = TextEditingController(
    text: widget.variant?.size ?? '',
  );
  late final TextEditingController _colorController = TextEditingController(
    text: widget.variant?.color ?? '',
  );
  late final TextEditingController _priceController = TextEditingController(
    text: widget.variant?.price.toString() ?? '',
  );
  late final TextEditingController _stockController = TextEditingController(
    text: widget.variant?.stockQuantity.toString() ?? '',
  );
  late final TextEditingController _imageController = TextEditingController(
    text: widget.variant?.imageUrls.join(', ') ?? '',
  );

  @override
  void dispose() {
    _skuController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.pop(context, {
      'id': widget.variant?.id,
      'sku': _skuController.text.trim(),
      'size': _sizeController.text.trim(),
      'color': _colorController.text.trim(),
      'price': int.tryParse(_priceController.text.trim()) ?? 0,
      'stockQuantity': int.tryParse(_stockController.text.trim()) ?? 0,
      'imageUrls': _imageController.text
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.variant != null;
    return AlertDialog(
      title: Text(isEditing ? 'Sửa biến thể' : 'Thêm biến thể'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(
                controller: _skuController,
                label: 'SKU',
                required: true,
              ),
              _DialogField(controller: _sizeController, label: 'Size'),
              _DialogField(controller: _colorController, label: 'Màu'),
              _DialogField(
                controller: _priceController,
                label: 'Giá',
                keyboardType: TextInputType.number,
                required: true,
              ),
              _DialogField(
                controller: _stockController,
                label: 'Tồn kho',
                keyboardType: TextInputType.number,
                required: true,
              ),
              _DialogField(
                controller: _imageController,
                label: 'Ảnh URL',
                hint: 'Ngăn cách nhiều URL bằng dấu phẩy',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'Vui lòng nhập $label.';
          }
          return null;
        },
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.product});

  final ProductDetailModel product;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Quản lý kho hàng',
        style: AppTextStyles.display.copyWith(fontSize: 36),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        'Kiểm soát biến thể và tồn kho cho ${product.name}.',
        style: AppTextStyles.body.copyWith(
          color: AdminColors.textSecondary,
          fontSize: 18,
        ),
      ),
    ],
  );
}
