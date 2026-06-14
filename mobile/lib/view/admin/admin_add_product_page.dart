import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

class AdminAddProductPage extends StatefulWidget {
  const AdminAddProductPage({super.key});

  @override
  State<AdminAddProductPage> createState() => _AdminAddProductPageState();
}

class _AdminAddProductPageState extends State<AdminAddProductPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _sportController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _sportController.dispose();
    _skuController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    final success = await _controller.saveProduct(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryName: _categoryController.text.trim(),
      brandName: _brandController.text.trim(),
      sportName: _sportController.text.trim(),
      variants: [_variantPayload()],
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã thêm sản phẩm.'
              : (_controller.errorMessage ?? 'Chưa thêm được sản phẩm.'),
        ),
      ),
    );
    if (success) {
      context.go(AppRoutes.adminProducts);
    }
  }

  Map<String, dynamic> _variantPayload() {
    final images = _imageController.text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    return {
      'size': _sizeController.text.trim(),
      'color': _colorController.text.trim(),
      'price': int.tryParse(_priceController.text.trim()) ?? 0,
      'stockQuantity': int.tryParse(_stockController.text.trim()) ?? 0,
      'sku': _skuController.text.trim(),
      'imageUrls': images,
    };
  }

  void _closePage() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.adminProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _closePage,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Thêm sản phẩm mới'),
        actions: [
          IconButton(onPressed: _closePage, icon: const Icon(Icons.close)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const _StepperHeader(),
            const SizedBox(height: AppSpacing.xl),
            const _CoverPicker(),
            const SizedBox(height: AppSpacing.xl),
            const _FormIntro(),
            const SizedBox(height: AppSpacing.xl),
            _LabeledInput(
              controller: _nameController,
              label: 'TÊN SẢN PHẨM *',
              hint: 'Ví dụ: Giày Chạy Apex Pro V1',
              required: true,
            ),
            _LabeledInput(
              controller: _descriptionController,
              label: 'MÔ TẢ',
              hint: 'Mô tả ngắn về sản phẩm',
              minLines: 3,
            ),
            Row(
              children: [
                Expanded(
                  child: _LabeledInput(
                    controller: _categoryController,
                    label: 'DANH MỤC *',
                    hint: 'Giày chạy bộ',
                    required: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _LabeledInput(
                    controller: _brandController,
                    label: 'THƯƠNG HIỆU *',
                    hint: 'Nike',
                    required: true,
                  ),
                ),
              ],
            ),
            _LabeledInput(
              controller: _sportController,
              label: 'MÔN THỂ THAO',
              hint: 'Running',
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Biến thể đầu tiên',
              style: AppTextStyles.display.copyWith(fontSize: 28),
            ),
            const SizedBox(height: AppSpacing.md),
            _LabeledInput(
              controller: _skuController,
              label: 'MÃ SKU *',
              hint: 'APX-RUN-2026-001',
              required: true,
              suffixIcon: Icons.qr_code_scanner,
            ),
            Row(
              children: [
                Expanded(
                  child: _LabeledInput(
                    controller: _sizeController,
                    label: 'SIZE',
                    hint: '42',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _LabeledInput(
                    controller: _colorController,
                    label: 'MÀU',
                    hint: 'Đỏ',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _LabeledInput(
                    controller: _priceController,
                    label: 'GIÁ *',
                    hint: '2450000',
                    keyboardType: TextInputType.number,
                    required: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _LabeledInput(
                    controller: _stockController,
                    label: 'TỒN KHO *',
                    hint: '20',
                    keyboardType: TextInputType.number,
                    required: true,
                  ),
                ),
              ],
            ),
            _LabeledInput(
              controller: _imageController,
              label: 'ẢNH URL',
              hint: 'Nhập nhiều URL, ngăn cách bằng dấu phẩy',
            ),
            const _TipBox(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            label: _controller.isSubmitting ? 'ĐANG LƯU...' : 'LƯU SẢN PHẨM',
            variant: AppButtonVariant.secondary,
            onPressed: _controller.isSubmitting ? null : _submit,
          ),
        ),
      ),
    );
  }
}

class _StepperHeader extends StatelessWidget {
  const _StepperHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _StepCircle(number: '1', label: 'Cơ bản', active: true),
        Expanded(child: Divider(color: AppColors.secondary)),
        _StepCircle(number: '2', label: 'Biến thể', active: true),
        Expanded(child: Divider(color: AppColors.secondary)),
        _StepCircle(number: '3', label: 'Lưu'),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.number,
    required this.label,
    this.active = false,
  });

  final String number;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: active
              ? AppColors.secondary
              : AppColors.surfaceMuted,
          foregroundColor: active ? Colors.white : AppColors.primary,
          child: Text(number),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: active ? AppColors.secondary : AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _CoverPicker extends StatelessWidget {
  const _CoverPicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_a_photo, size: 54),
            SizedBox(height: AppSpacing.md),
            Text(
              'ẢNH BÌA SẢN PHẨM',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormIntro extends StatelessWidget {
  const _FormIntro();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Thông tin chung',
        style: AppTextStyles.display.copyWith(fontSize: 34),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        'Nhập thông tin sản phẩm và biến thể đầu tiên để tạo hàng trong kho.',
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
          fontSize: 18,
        ),
      ),
    ],
  );
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.controller,
    required this.label,
    required this.hint,
    this.suffixIcon,
    this.keyboardType,
    this.minLines = 1,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final int minLines;
  final bool required;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: minLines == 1 ? 1 : 5,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon == null ? null : Icon(suffixIcon),
          ),
          validator: (value) {
            if (required && (value == null || value.trim().isEmpty)) {
              return 'Vui lòng nhập thông tin.';
            }
            return null;
          },
        ),
      ],
    ),
  );
}

class _TipBox extends StatelessWidget {
  const _TipBox();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: const Border(
        left: BorderSide(color: AppColors.secondary, width: 4),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Mẹo nhỏ\nTên danh mục, thương hiệu và môn thể thao cần khớp dữ liệu backend để sản phẩm được phân loại đúng.',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    ),
  );
}
