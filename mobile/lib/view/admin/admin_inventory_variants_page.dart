import 'package:flutter/material.dart';

import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/customer/product_detail_model.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminInventoryVariantsPage extends StatefulWidget {
  const AdminInventoryVariantsPage({super.key, required this.productId});

  final String productId;

  @override
  State<AdminInventoryVariantsPage> createState() =>
      _AdminInventoryVariantsPageState();
}

class _AdminInventoryVariantsPageState
    extends State<AdminInventoryVariantsPage> {
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadProductDetail(widget.productId);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openVariantForm([ProductVariantModel? variant]) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _VariantFormDialog(variant: variant),
    );
    if (result == null) {
      return;
    }

    final success = await _controller.saveVariant(
      productId: widget.productId,
      variantId: variant?.id,
      variant: result,
    );
    if (!mounted) {
      return;
    }
    _showResult(
      success,
      variant == null ? 'Đã thêm biến thể.' : 'Đã cập nhật biến thể.',
    );
  }

  Future<void> _deleteVariant(ProductVariantModel variant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa biến thể?'),
        content: Text('Bạn có chắc muốn xóa SKU ${variant.sku} không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    final success = await _controller.deleteVariant(
      productId: widget.productId,
      variantId: variant.id,
    );
    if (!mounted) {
      return;
    }
    _showResult(success, 'Đã xóa biến thể.');
  }

  Future<void> _updateStock(ProductVariantModel variant, int quantity) async {
    if (quantity < 0) {
      return;
    }
    final success = await _controller.updateVariantStock(
      productId: widget.productId,
      variantId: variant.id,
      quantity: quantity,
    );
    if (!mounted) {
      return;
    }
    _showResult(success, 'Đã cập nhật tồn kho.');
  }

  void _showResult(bool success, String successMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? successMessage
              : (_controller.errorMessage ?? 'Thao tác chưa thành công.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _controller.selectedProduct;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý kho hàng'),
        actions: [
          IconButton(
            onPressed: _controller.isLoading
                ? null
                : () => _controller.loadProductDetail(widget.productId),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _controller.loadProductDetail(widget.productId),
        child: _buildBody(product),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        onPressed: _controller.isSubmitting ? null : () => _openVariantForm(),
        child: _controller.isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildBody(ProductDetailModel? product) {
    if (_controller.isLoading && product == null) {
      return const AppLoadingState(title: 'Đang tải biến thể');
    }
    if (_controller.errorMessage != null && product == null) {
      return AppErrorState(
        title: 'Không tải được kho hàng',
        message: _controller.errorMessage!,
        onAction: () => _controller.loadProductDetail(widget.productId),
      );
    }
    if (product == null) {
      return const AppEmptyState(title: 'Chưa có dữ liệu sản phẩm');
    }

    final variants = product.variants;
    final totalStock = variants.fold<int>(
      0,
      (sum, variant) => sum + variant.stockQuantity,
    );
    final lowStock = variants
        .where((variant) => variant.stockQuantity <= 5)
        .length;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _Title(product: product),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: _StockSummary(
                title: 'CẢNH BÁO',
                value: lowStock.toString().padLeft(2, '0'),
                subtitle: 'Biến thể sắp hết hàng',
                alert: true,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _StockSummary(
                title: 'TỔNG TỒN',
                value: '$totalStock',
                subtitle: 'Sản phẩm hiện có',
                dark: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _InventoryChip(label: 'Tất cả', active: true),
            _InventoryChip(label: 'Sắp hết'),
            _InventoryChip(label: 'Còn hàng'),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        if (variants.isEmpty)
          const AppEmptyState(
            title: 'Chưa có biến thể',
            message: 'Bấm nút + để thêm size, màu, SKU và tồn kho.',
          )
        else
          ...variants.map(
            (variant) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _VariantCard(
                variant: variant,
                onDecrease: () =>
                    _updateStock(variant, variant.stockQuantity - 1),
                onIncrease: () =>
                    _updateStock(variant, variant.stockQuantity + 1),
                onEdit: () => _openVariantForm(variant),
                onDelete: () => _deleteVariant(variant),
              ),
            ),
          ),
      ],
    );
  }
}

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
          color: AppColors.textSecondary,
          fontSize: 18,
        ),
      ),
    ],
  );
}

class _StockSummary extends StatelessWidget {
  const _StockSummary({
    required this.title,
    required this.value,
    required this.subtitle,
    this.alert = false,
    this.dark = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final bool alert;
  final bool dark;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: dark ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      border: alert
          ? const Border(left: BorderSide(color: AppColors.secondary, width: 4))
          : null,
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: dark ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.display.copyWith(
              fontSize: 42,
              color: dark ? Colors.white : AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTextStyles.body.copyWith(
              color: dark ? Colors.white70 : AppColors.primary,
            ),
          ),
        ],
      ),
    ),
  );
}

class _InventoryChip extends StatelessWidget {
  const _InventoryChip({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(label),
    backgroundColor: active ? AppColors.primary : AppColors.surfaceMuted,
    labelStyle: TextStyle(
      color: active ? Colors.white : AppColors.primary,
      fontWeight: FontWeight.w900,
    ),
  );
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({
    required this.variant,
    required this.onDecrease,
    required this.onIncrease,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductVariantModel variant;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final alert = variant.stockQuantity <= 5;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.directions_run,
                color: alert ? AppColors.secondary : AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (alert)
                    const Chip(
                      label: Text('SẮP HẾT'),
                      backgroundColor: Color(0xFFFCE8EE),
                      labelStyle: TextStyle(color: AppColors.secondary),
                    ),
                  Text('SKU: ${variant.sku}', style: AppTextStyles.subtitle),
                  Text(
                    'Màu ${variant.color} • Size ${variant.size}',
                    style: AppTextStyles.body.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _QtyButton(label: '-', onTap: onDecrease),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          '${variant.stockQuantity}',
                          style: AppTextStyles.title,
                        ),
                      ),
                      _QtyButton(label: '+', onTap: onIncrease),
                      const Spacer(),
                      Text(
                        'Còn ${variant.stockQuantity} SP',
                        style: AppTextStyles.body.copyWith(
                          color: alert
                              ? AppColors.secondary
                              : AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Sửa')),
                PopupMenuItem(value: 'delete', child: Text('Xóa')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppRadius.sm),
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: label == '+' ? AppColors.primary : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: label == '+' ? Colors.white : AppColors.primary,
            fontSize: 22,
          ),
        ),
      ),
    ),
  );
}
