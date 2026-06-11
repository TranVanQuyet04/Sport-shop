import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/customer/product_detail_model.dart';
import '../../model/customer/product_summary_model.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadProducts();
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

  Future<void> _editProduct(ProductSummaryModel product) async {
    await _controller.loadProductDetail(product.id);
    if (!mounted) {
      return;
    }

    final detail = _controller.selectedProduct;
    if (detail == null) {
      _showResult(false, 'Không tải được chi tiết sản phẩm.');
      return;
    }

    final result = await showDialog<_ProductFormResult>(
      context: context,
      builder: (_) => _ProductFormDialog(product: detail),
    );
    if (result == null) {
      return;
    }

    final success = await _controller.saveProduct(
      id: detail.id,
      name: result.name,
      description: result.description,
      categoryName: result.categoryName,
      brandName: result.brandName,
      sportName: result.sportName,
      variants: detail.variants.map(_variantPayload).toList(),
    );
    if (!mounted) {
      return;
    }
    _showResult(success, 'Đã cập nhật sản phẩm.');
  }

  Future<void> _deleteProduct(ProductSummaryModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: Text('Bạn có chắc muốn xóa "${product.name}" không?'),
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

    final success = await _controller.deleteProduct(product.id);
    if (!mounted) {
      return;
    }
    _showResult(success, 'Đã xóa sản phẩm.');
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

  Map<String, dynamic> _variantPayload(ProductVariantModel variant) {
    return {
      'id': int.tryParse(variant.id),
      'size': variant.size,
      'color': variant.color,
      'price': variant.price,
      'stockQuantity': variant.stockQuantity,
      'sku': variant.sku,
      'imageUrls': variant.imageUrls,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _controller.loadProducts,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        onPressed: () => context.go(AppRoutes.adminAddProduct),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.products.isEmpty) {
      return const AppLoadingState(title: 'Đang tải sản phẩm');
    }
    if (_controller.errorMessage != null && _controller.products.isEmpty) {
      return AppErrorState(
        title: 'Không tải được sản phẩm',
        message: _controller.errorMessage!,
        onAction: _controller.loadProducts,
      );
    }
    if (_controller.products.isEmpty) {
      return const AppEmptyState(title: 'Chưa có sản phẩm');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _controller.products.length + 3,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm kiếm sản phẩm, SKU...',
            ),
          );
        }
        if (index == 1) {
          return const Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _FilterButton(icon: Icons.credit_card, label: 'Thương hiệu'),
              _FilterButton(icon: Icons.category_outlined, label: 'Danh mục'),
              _FilterButton(icon: Icons.inventory_outlined, label: 'Tồn kho'),
              _FilterButton(
                icon: Icons.tune,
                label: 'Lọc nâng cao',
                active: true,
              ),
            ],
          );
        }
        if (index == 2) {
          return Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.adminCategories),
                  icon: const Icon(Icons.category),
                  label: const Text('Danh mục'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.adminBrands),
                  icon: const Icon(Icons.verified),
                  label: const Text('Thương hiệu'),
                ),
              ),
            ],
          );
        }
        final product = _controller.products[index - 3];
        return _ProductAdminCard(
          product: product,
          onEdit: () => _editProduct(product),
          onDelete: () => _deleteProduct(product),
        );
      },
    );
  }
}

class _ProductFormResult {
  const _ProductFormResult({
    required this.name,
    required this.description,
    required this.categoryName,
    required this.brandName,
    required this.sportName,
  });

  final String name;
  final String description;
  final String categoryName;
  final String brandName;
  final String sportName;
}

class _ProductFormDialog extends StatefulWidget {
  const _ProductFormDialog({required this.product});

  final ProductDetailModel product;

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.product.name,
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.product.description);
  late final TextEditingController _categoryController = TextEditingController(
    text: widget.product.category,
  );
  late final TextEditingController _brandController = TextEditingController(
    text: widget.product.brand,
  );
  late final TextEditingController _sportController = TextEditingController(
    text: widget.product.sport,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _sportController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.pop(
      context,
      _ProductFormResult(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryName: _categoryController.text.trim(),
        brandName: _brandController.text.trim(),
        sportName: _sportController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sửa thông tin sản phẩm'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(
                controller: _nameController,
                label: 'Tên sản phẩm',
                required: true,
              ),
              _DialogField(
                controller: _descriptionController,
                label: 'Mô tả',
                minLines: 3,
              ),
              _DialogField(
                controller: _categoryController,
                label: 'Danh mục',
                required: true,
              ),
              _DialogField(
                controller: _brandController,
                label: 'Thương hiệu',
                required: true,
              ),
              _DialogField(controller: _sportController, label: 'Môn thể thao'),
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
    this.minLines = 1,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final int minLines;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: minLines == 1 ? 1 : 5,
        decoration: InputDecoration(labelText: label),
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

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? AppColors.secondary : AppColors.surface,
        foregroundColor: active ? Colors.white : AppColors.primary,
      ),
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _ProductAdminCard extends StatelessWidget {
  const _ProductAdminCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductSummaryModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final priceText = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(product.price);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.directions_run,
                color: AppColors.secondary,
                size: 110,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: AppTextStyles.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('#${product.id}', style: AppTextStyles.caption),
                  ],
                ),
                Text(
                  '${product.category} • ${product.brand}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GIÁ NIÊM YẾT', style: AppTextStyles.caption),
                          Text(
                            '$priceTextđ',
                            style: AppTextStyles.display.copyWith(fontSize: 28),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit();
                        } else if (value == 'variants') {
                          context.go('/admin/products/${product.id}/variants');
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Sửa thông tin'),
                        ),
                        PopupMenuItem(
                          value: 'variants',
                          child: Text('Biến thể / kho'),
                        ),
                        PopupMenuItem(value: 'delete', child: Text('Xóa')),
                      ],
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
