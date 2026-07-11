import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../presenter/admin/admin_catalog_presenter.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/brand_logo_url_validator.dart';
import '../../core/widgets/app_button.dart';
import '../../model/admin/collection_model.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../model/common/backend_models.dart';
import 'widgets/admin_design_system.dart';

part 'admin_add_product_page_parts/premium_dropdown.dart';
part 'admin_add_product_page_parts/product_form_support_widgets.dart';
part 'admin_add_product_page_parts/add_product_state_helpers.dart';
part 'admin_add_product_page_parts/quick_add_dialogs.dart';

class AdminAddProductPage extends StatefulWidget {
  const AdminAddProductPage({super.key});

  @override
  State<AdminAddProductPage> createState() => _AdminAddProductPageState();
}

class _AdminAddProductPageState extends State<AdminAddProductPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final AdminCatalogPresenter _presenter = AdminCatalogPresenter(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  List<SportModel> _sports = const [];
  List<CollectionModel> _collections = const [];
  List<AdminCategoryModel> _categories = const [];
  List<AdminBrandModel> _brands = const [];
  SportModel? _selectedSport;
  CollectionModel? _selectedCollection;
  AdminCategoryModel? _selectedCategory;
  AdminBrandModel? _selectedBrand;
  bool _isLoadingLookups = true;
  String? _lookupError;

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _loadLookups();
  }

  @override
  void dispose() {
    _presenter
      ..removeListener(_onControllerChanged)
      ..dispose();
    _nameController.dispose();
    _descriptionController.dispose();
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

  Future<void> _loadLookups() async {
    setState(() {
      _isLoadingLookups = true;
      _lookupError = null;
    });
    try {
      final repository = AppDependencies.instance.adminCatalogRepository;
      final results = await Future.wait<Object>([
        repository.getSports(),
        repository.getCollections(),
        repository.getCategories(),
        repository.getBrands(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _sports = results[0] as List<SportModel>;
        _collections = (results[1] as List<CollectionModel>)
            .where((collection) => collection.isActive)
            .toList(growable: false);
        _categories = results[2] as List<AdminCategoryModel>;
        _brands = results[3] as List<AdminBrandModel>;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _lookupError = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLookups = false);
      }
    }
  }

  void updateState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    final success = await _presenter.saveProduct(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryName: _selectedCategory?.name ?? '',
      brandName: _selectedBrand?.name ?? '',
      sportName: _selectedSport?.name ?? '',
      variants: [_variantPayload()],
    );
    if (!mounted) {
      return;
    }
    var collectionLinked = true;
    if (success && _selectedCollection != null) {
      final variantIds =
          _presenter.selectedProduct?.variants
              .map((variant) => variant.id)
              .where((id) => id.isNotEmpty)
              .toList(growable: false) ??
          const <String>[];
      try {
        if (variantIds.isNotEmpty) {
          await AppDependencies.instance.adminCatalogRepository
              .addVariantsToCollection(
                collection: _selectedCollection!,
                variantIds: variantIds,
              );
        }
      } catch (_) {
        collectionLinked = false;
      }
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã thêm sản phẩm.'
              : (_presenter.errorMessage ?? 'Chưa thêm được sản phẩm.'),
        ),
      ),
    );
    if (success && !collectionLinked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sản phẩm đã được tạo nhưng chưa liên kết được bộ sưu tập.',
          ),
        ),
      );
    }
    if (success) {
      context.go(AppRoutes.adminProducts);
    }
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
                    if (_lookupError != null) ...[
                      AdminInlineBanner(
                        message: 'Không tải được môn thể thao hoặc bộ sưu tập.',
                        isError: true,
                        onRefresh: _loadLookups,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    _ResponsiveFieldPair(
                      first: Column(
                        children: [
                          _PremiumDropdown<AdminCategoryModel>(
                            label: 'Danh mục',
                            hintText: _isLoadingLookups
                                ? 'Đang tải danh mục...'
                                : 'Chọn danh mục',
                            fieldIcon: Icons.category_outlined,
                            value: _selectedCategory,
                            items: _categories,
                            enabled: !_isLoadingLookups,
                            required: true,
                            itemLabel: (cat) => cat.name,
                            itemIcon: (_) => Icons.category_outlined,
                            onChanged: (value) {
                              setState(() => _selectedCategory = value);
                            },
                            onQuickAdd: _onQuickAddCategory,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _PremiumDropdown<SportModel>(
                            label: 'Môn thể thao',
                            hintText: _isLoadingLookups
                                ? 'Đang tải môn thể thao...'
                                : 'Chọn môn thể thao',
                            fieldIcon: Icons.sports_soccer_outlined,
                            value: _selectedSport,
                            items: _sports,
                            enabled: !_isLoadingLookups,
                            required: true,
                            itemLabel: (sport) => sport.name,
                            itemIcon: (sport) => _sportIcon(sport.name),
                            onChanged: (value) {
                              setState(() => _selectedSport = value);
                            },
                            onQuickAdd: _onQuickAddSport,
                          ),
                        ],
                      ),
                      second: Column(
                        children: [
                          _PremiumDropdown<AdminBrandModel>(
                            label: 'Thương hiệu',
                            hintText: _isLoadingLookups
                                ? 'Đang tải thương hiệu...'
                                : 'Chọn thương hiệu',
                            fieldIcon: Icons.verified_outlined,
                            value: _selectedBrand,
                            items: _brands,
                            enabled: !_isLoadingLookups,
                            required: true,
                            itemLabel: (brand) => brand.name,
                            itemIcon: (_) => Icons.verified_outlined,
                            onChanged: (value) {
                              setState(() => _selectedBrand = value);
                            },
                            onQuickAdd: _onQuickAddBrand,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _PremiumDropdown<CollectionModel>(
                            label: 'Bộ sưu tập',
                            hintText: _isLoadingLookups
                                ? 'Đang tải bộ sưu tập...'
                                : 'Không thuộc bộ sưu tập',
                            fieldIcon: Icons.collections_bookmark_outlined,
                            value: _selectedCollection,
                            items: _collections,
                            enabled: !_isLoadingLookups,
                            itemLabel: (collection) => collection.name,
                            itemIcon: (_) =>
                                Icons.collections_bookmark_outlined,
                            onChanged: (value) {
                              setState(() => _selectedCollection = value);
                            },
                          ),
                        ],
                      ),
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
        submitting: _presenter.isSubmitting,
        onSubmit: _submit,
      ),
    );
  }
}
