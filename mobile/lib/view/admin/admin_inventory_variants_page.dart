import 'package:flutter/material.dart';

import '../../presenter/admin/admin_catalog_presenter.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/hover_effect.dart';
import '../../model/customer/product_detail_model.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

part 'admin_inventory_variants_page_parts/variant_form_dialog.dart';
part 'admin_inventory_variants_page_parts/inventory_summary_widgets.dart';

class AdminInventoryVariantsPage extends StatefulWidget {
  const AdminInventoryVariantsPage({super.key, required this.productId});

  final String productId;

  @override
  State<AdminInventoryVariantsPage> createState() =>
      _AdminInventoryVariantsPageState();
}

class _AdminInventoryVariantsPageState
    extends State<AdminInventoryVariantsPage> {
  late final AdminCatalogPresenter _presenter = AdminCatalogPresenter(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadProductDetail(widget.productId);
  }

  @override
  void dispose() {
    _presenter
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

    final success = await _presenter.saveVariant(
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

    final success = await _presenter.deleteVariant(
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
    final success = await _presenter.updateVariantStock(
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
              : (_presenter.errorMessage ?? 'Thao tác chưa thành công.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _presenter.selectedProduct;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý kho hàng'),
        actions: [
          IconButton(
            tooltip: 'Làm mới kho hàng',
            onPressed: _presenter.isLoading
                ? null
                : () => _presenter.loadProductDetail(widget.productId),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _presenter.loadProductDetail(widget.productId),
        child: _buildBody(product),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm biến thể',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: _presenter.isSubmitting ? null : () => _openVariantForm(),
        child: _presenter.isSubmitting
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
    if (_presenter.isLoading && product == null) {
      return const AppLoadingState(title: 'Đang tải biến thể');
    }
    if (_presenter.errorMessage != null && product == null) {
      return AppErrorState(
        title: 'Không tải được kho hàng',
        message: _presenter.errorMessage!,
        onAction: () => _presenter.loadProductDetail(widget.productId),
      );
    }
    if (product == null) {
      return PremiumEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Chưa có dữ liệu sản phẩm',
        message: 'Không tìm thấy sản phẩm để quản lý biến thể và tồn kho.',
        actionLabel: 'Tải lại dữ liệu',
        onAction: () => _presenter.loadProductDetail(widget.productId),
      );
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
          PremiumEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'Chưa có biến thể',
            message: 'Bấm nút + để thêm size, màu, SKU và tồn kho.',
            actionLabel: 'Thêm biến thể',
            onAction: () => _openVariantForm(),
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
