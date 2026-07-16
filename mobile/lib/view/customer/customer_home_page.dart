import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/device_profiles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/hover_effect.dart';
import '../../core/widgets/sport_performance_hero.dart';
import '../../model/common/backend_models.dart';
import '../../presenter/customer/customer_home_presenter.dart';
import 'widgets/customer_bottom_nav.dart';
import 'widgets/product_card.dart';
import 'widgets/sportshop_logo.dart';

part 'customer_home_page_parts/home_navigation_widgets.dart';
part 'customer_home_page_parts/home_sections_and_hero.dart';
part 'customer_home_page_parts/home_grid_widgets.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _offerKey = GlobalKey();
  final GlobalKey _categoryKey = GlobalKey();
  final GlobalKey _brandKey = GlobalKey();
  final GlobalKey _productKey = GlobalKey();

  late final CustomerHomePresenter _presenter = CustomerHomePresenter(
    productRepository: AppDependencies.instance.productRepository,
    navigationRepository: AppDependencies.instance.navigationRepository,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onControllerChanged);
    _presenter.loadHome();
  }

  @override
  void dispose() {
    _presenter
      ..removeListener(_onControllerChanged)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _flattenCategories(_presenter.categories);
    final brands = _presenter.brands
        .where((brand) => brand.name.isNotEmpty)
        .toList(growable: false);

    return Scaffold(
      key: _scaffoldKey,
      drawer: _HomeDrawer(
        categories: categories,
        onSelect: _handleDrawerSelection,
      ),
      body: Column(
        children: [
          const _PromoBar(),
          _ShopNav(
            onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
            onSearch: () => context.go(AppRoutes.search),
            onCart: () => context.go(AppRoutes.cart),
            onRefresh: _presenter.isLoading ? null : _presenter.loadHome,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _presenter.loadHome,
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    child: _Breadcrumb(
                      items: const ['Trang chủ', 'Ưu đãi cuối mùa'],
                      onHomeTap: () => _scrollTo(_offerKey),
                    ),
                  ),
                  _HomeSection(
                    key: _offerKey,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    child: const _SeasonSaleHero(),
                  ),
                  _HomeSection(
                    key: _categoryKey,
                    title: 'Danh mục mua sắm',
                    actionLabel: 'Xem tất cả',
                    onAction: () => _scrollTo(_productKey),
                    child: categories.isEmpty
                        ? const AppEmptyState(
                            title: 'Chưa có danh mục',
                            message: 'Backend chưa trả về danh mục hiển thị.',
                          )
                        : _CategoryRail(
                            categories: categories.take(8).toList(),
                            onTap: (category) => _loadCategory(category),
                          ),
                  ),
                  _HomeSection(
                    key: _brandKey,
                    title: 'Thương hiệu nổi bật',
                    subtitle: 'Dữ liệu lấy trực tiếp từ backend',
                    child: brands.isEmpty
                        ? const AppEmptyState(
                            title: 'Chưa có thương hiệu',
                            message:
                                'Backend chưa trả về thương hiệu hiển thị.',
                          )
                        : _BrandGrid(
                            brands: brands.take(4).toList(),
                            onTap: _loadBrand,
                          ),
                  ),
                  _HomeSection(
                    key: _productKey,
                    title: 'Sản phẩm gợi ý',
                    subtitle: 'Sẵn sàng cho mọi buổi tập',
                    trailing: IconButton(
                      tooltip: 'Bộ lọc',
                      onPressed: () => context.go(AppRoutes.search),
                      icon: const Icon(Icons.tune),
                    ),
                    child: _ProductGrid(controller: _presenter),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedIndex: 0),
    );
  }

  List<NavigationCategoryModel> _flattenCategories(
    List<NavigationCategoryModel> categories,
  ) {
    final result = <NavigationCategoryModel>[];
    for (final category in categories) {
      if (category.name.isNotEmpty) {
        result.add(category);
      }
      result.addAll(_flattenCategories(category.children));
    }
    return result;
  }

  void _handleDrawerSelection(String label) {
    Navigator.pop(context);

    switch (label) {
      case 'Ưu đãi':
        _scrollTo(_offerKey);
        return;
      case 'Thương hiệu':
        _scrollTo(_brandKey);
        return;
      case 'Tra cứu đơn hàng':
        context.go(AppRoutes.orders);
        return;
      case 'Tìm kiếm':
        context.go(AppRoutes.search);
        return;
      default:
        final category = _findCategory(label);
        if (category != null) {
          _loadCategory(category);
        } else {
          _scrollTo(_productKey);
        }
    }
  }

  NavigationCategoryModel? _findCategory(String label) {
    final normalizedLabel = _normalize(label);
    for (final category in _flattenCategories(_presenter.categories)) {
      final categoryName = _normalize(category.name);
      if (categoryName.contains(normalizedLabel) ||
          normalizedLabel.contains(categoryName)) {
        return category;
      }
    }
    return null;
  }

  Future<void> _loadCategory(NavigationCategoryModel category) async {
    await _presenter.loadProducts(categoryId: category.id);
    if (mounted) {
      _scrollTo(_productKey);
    }
  }

  Future<void> _loadBrand(BrandModel brand) async {
    await _presenter.loadProducts(brandId: brand.id);
    if (mounted) {
      _scrollTo(_productKey);
    }
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(
          RegExp(
            '[\u00e0\u00e1\u1ea1\u1ea3\u00e3\u00e2\u1ea7\u1ea5\u1ead\u1ea9\u1eab\u0103\u1eb1\u1eaf\u1eb7\u1eb3\u1eb5]',
          ),
          'a',
        )
        .replaceAll(
          RegExp(
            '[\u00e8\u00e9\u1eb9\u1ebb\u1ebd\u00ea\u1ec1\u1ebf\u1ec7\u1ec3\u1ec5]',
          ),
          'e',
        )
        .replaceAll(RegExp('[\u00ec\u00ed\u1ecb\u1ec9\u0129]'), 'i')
        .replaceAll(
          RegExp(
            '[\u00f2\u00f3\u1ecd\u1ecf\u00f5\u00f4\u1ed3\u1ed1\u1ed9\u1ed5\u1ed7\u01a1\u1edd\u1edb\u1ee3\u1edf\u1ee1]',
          ),
          'o',
        )
        .replaceAll(
          RegExp(
            '[\u00f9\u00fa\u1ee5\u1ee7\u0169\u01b0\u1eeb\u1ee9\u1ef1\u1eed\u1eef]',
          ),
          'u',
        )
        .replaceAll(RegExp('[\u1ef3\u00fd\u1ef5\u1ef7\u1ef9]'), 'y')
        .replaceAll('\u0111', 'd');
  }
}
