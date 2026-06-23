import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import 'widgets/admin_design_system.dart';

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
          tooltip: 'Quay lại',
          onPressed: _closePage,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Thêm sản phẩm mới'),
        actions: [
          IconButton(
            tooltip: 'Đóng',
            onPressed: _closePage,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              const AdminProgressStepper(
                steps: ['Cơ bản', 'Biến thể', 'Lưu'],
                currentStep: 1,
              ),
              const SizedBox(height: AppSpacing.xl),
              const _FormHeader(),
              const SizedBox(height: AppSpacing.xl),
              AdminFormSection(
                title: 'Thông tin chung',
                subtitle:
                    'Tên, mô tả và cách sản phẩm được phân loại trong hệ thống.',
                icon: Icons.inventory_2_outlined,
                child: Column(
                  children: [
                    AdminFormField(
                      controller: _nameController,
                      label: 'Tên sản phẩm',
                      hintText: 'Ví dụ: Giày chạy Apex Pro V1',
                      prefixIcon: Icons.shopping_bag_outlined,
                      required: true,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AdminFormField(
                      controller: _descriptionController,
                      label: 'Mô tả',
                      hintText: 'Mô tả ngắn về sản phẩm',
                      prefixIcon: Icons.notes_rounded,
                      minLines: 3,
                      maxLines: 5,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _ResponsiveFieldPair(
                      first: AdminFormField(
                        controller: _categoryController,
                        label: 'Danh mục',
                        hintText: 'Giày chạy bộ',
                        prefixIcon: Icons.category_outlined,
                        required: true,
                        textInputAction: TextInputAction.next,
                      ),
                      second: AdminFormField(
                        controller: _brandController,
                        label: 'Thương hiệu',
                        hintText: 'Nike',
                        prefixIcon: Icons.verified_outlined,
                        required: true,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AdminFormField(
                      controller: _sportController,
                      label: 'Môn thể thao',
                      hintText: 'Running',
                      prefixIcon: Icons.sports_soccer_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AdminFormSection(
                title: 'Biến thể đầu tiên',
                subtitle:
                    'Thiết lập SKU, thuộc tính bán hàng, giá và số lượng tồn kho.',
                icon: Icons.tune_rounded,
                child: Column(
                  children: [
                    AdminFormField(
                      controller: _skuController,
                      label: 'Mã SKU',
                      hintText: 'APX-RUN-2026-001',
                      prefixIcon: Icons.qr_code_2_rounded,
                      suffixIcon: Icons.qr_code_scanner_rounded,
                      required: true,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _ResponsiveFieldPair(
                      first: AdminFormField(
                        controller: _sizeController,
                        label: 'Kích thước',
                        hintText: '42',
                        prefixIcon: Icons.straighten_rounded,
                        textInputAction: TextInputAction.next,
                      ),
                      second: AdminFormField(
                        controller: _colorController,
                        label: 'Màu sắc',
                        hintText: 'Đỏ',
                        prefixIcon: Icons.palette_outlined,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _ResponsiveFieldPair(
                      first: AdminFormField(
                        controller: _priceController,
                        label: 'Giá bán',
                        hintText: '2450000',
                        prefixIcon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                        required: true,
                        textInputAction: TextInputAction.next,
                      ),
                      second: AdminFormField(
                        controller: _stockController,
                        label: 'Tồn kho',
                        hintText: '20',
                        prefixIcon: Icons.warehouse_outlined,
                        keyboardType: TextInputType.number,
                        required: true,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AdminFormField(
                      controller: _imageController,
                      label: 'URL hình ảnh',
                      hintText: 'Nhập nhiều URL, ngăn cách bằng dấu phẩy',
                      prefixIcon: Icons.image_outlined,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _TipBox(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _SaveBar(
        submitting: _controller.isSubmitting,
        onSubmit: _submit,
      ),
    );
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminIconBadge(
          icon: Icons.add_photo_alternate_outlined,
          size: 52,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tạo sản phẩm mới',
                style: AppTextStyles.display.copyWith(
                  color: AdminColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Hoàn thiện dữ liệu cơ bản và biến thể đầu tiên để đưa sản phẩm vào danh mục.',
                style: AppTextStyles.body.copyWith(
                  color: AdminColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResponsiveFieldPair extends StatelessWidget {
  const _ResponsiveFieldPair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: [
              first,
              const SizedBox(height: AppSpacing.lg),
              second,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _TipBox extends StatelessWidget {
  const _TipBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AdminColors.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AdminColors.accent.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminIconBadge(
            icon: Icons.lightbulb_outline_rounded,
            color: AdminColors.accent,
            backgroundColor: AdminColors.accentSoft,
            size: 40,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mẹo nhập liệu',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AdminColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tên danh mục, thương hiệu và môn thể thao cần khớp dữ liệu backend để sản phẩm được phân loại chính xác.',
                  style: AppTextStyles.body.copyWith(
                    color: AdminColors.label,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.submitting, required this.onSubmit});

  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        boxShadow: [
          BoxShadow(
            color: AdminColors.navy.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            label: submitting ? 'ĐANG LƯU...' : 'LƯU SẢN PHẨM',
            icon: Icons.save_outlined,
            isLoading: submitting,
            backgroundColor: AdminColors.primary,
            onPressed: submitting ? null : onSubmit,
          ),
        ),
      ),
    );
  }
}
