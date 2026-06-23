import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../controller/customer/customer_home_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/common/backend_models.dart';
import 'widgets/customer_bottom_nav.dart';
import 'widgets/product_card.dart';
import 'widgets/sportshop_logo.dart';

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

  late final CustomerHomeController _controller = CustomerHomeController(
    productRepository: AppDependencies.instance.productRepository,
    navigationRepository: AppDependencies.instance.navigationRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadHome();
  }

  @override
  void dispose() {
    _controller
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
    final categories = _flattenCategories(_controller.categories);
    final brands = _controller.brands
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
            onRefresh: _controller.isLoading ? null : _controller.loadHome,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _controller.loadHome,
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
                        : _BrandGrid(brands: brands.take(4).toList()),
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
                    child: _ProductGrid(controller: _controller),
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
    for (final category in _flattenCategories(_controller.categories)) {
      final categoryName = _normalize(category.name);
      if (categoryName.contains(normalizedLabel) ||
          normalizedLabel.contains(categoryName)) {
        return category;
      }
    }
    return null;
  }

  Future<void> _loadCategory(NavigationCategoryModel category) async {
    await _controller.loadProducts(categoryId: category.id);
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
        .replaceAll(RegExp('[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp('[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp('[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp('[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp('[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp('[ỳýỵỷỹ]'), 'y')
        .replaceAll('đ', 'd');
  }
}

class _PromoBar extends StatelessWidget {
  const _PromoBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.secondary,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 9,
        bottom: 9,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      child: Text(
        'ƯU ĐÃI CUỐI MÙA | GIẢM ĐẾN 50% - XEM NGAY',
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textInverse,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ShopNav extends StatelessWidget {
  const _ShopNav({
    required this.onOpenMenu,
    required this.onSearch,
    required this.onCart,
    required this.onRefresh,
  });

  final VoidCallback onOpenMenu;
  final VoidCallback onSearch;
  final VoidCallback onCart;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            _NavIconButton(
              tooltip: 'Mở menu',
              icon: Icons.menu,
              onPressed: onOpenMenu,
            ),
            const SizedBox(width: AppSpacing.xs),
            const Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SportshopLogo(compact: false, inverse: true),
              ),
            ),
            _NavIconButton(
              tooltip: 'Tìm kiếm',
              icon: Icons.search,
              onPressed: onSearch,
            ),
            _NavIconButton(
              tooltip: 'Giỏ hàng',
              icon: Icons.shopping_bag_outlined,
              onPressed: onCart,
            ),
            _NavIconButton(
              tooltip: 'Làm mới',
              icon: Icons.refresh,
              onPressed: onRefresh,
            ),
            Container(
              width: 32,
              height: 24,
              margin: const EdgeInsets.only(right: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              alignment: Alignment.center,
              child: const Text('★', style: TextStyle(color: Colors.yellow)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIconButton extends StatefulWidget {
  const _NavIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  State<_NavIconButton> createState() => _NavIconButtonState();
}

class _NavIconButtonState extends State<_NavIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: _hovered
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: IconButton(
          tooltip: widget.tooltip,
          onPressed: widget.onPressed,
          icon: Icon(widget.icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({required this.categories, required this.onSelect});

  final List<NavigationCategoryModel> categories;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final dynamicItems = categories
        .take(5)
        .map((category) => category.name)
        .where((name) => name.isNotEmpty)
        .toList();
    final items = <String>[
      'Xu hướng',
      ...dynamicItems,
      'Thương hiệu',
      'Thể thao',
      'Ưu đãi',
      'Tìm kiếm',
      'Tra cứu đơn hàng',
    ];

    return Drawer(
      width: MediaQuery.sizeOf(context).width.clamp(300, 360).toDouble(),
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Text('Menu', style: AppTextStyles.title),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Đóng menu',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isDeal = item == 'Ưu đãi';
                  final isLookup = item == 'Tra cứu đơn hàng';
                  return _DrawerEntry(
                    label: item,
                    icon: isLookup ? Icons.receipt_long_outlined : null,
                    accent: isDeal,
                    onTap: () => onSelect(item),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: SportshopLogo(compact: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerEntry extends StatefulWidget {
  const _DrawerEntry({
    required this.label,
    required this.onTap,
    this.icon,
    this.accent = false,
  });

  final String label;
  final IconData? icon;
  final bool accent;
  final VoidCallback onTap;

  @override
  State<_DrawerEntry> createState() => _DrawerEntryState();
}

class _DrawerEntryState extends State<_DrawerEntry> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        color: _hovered ? AppColors.surfaceMuted : AppColors.surface,
        child: ListTile(
          leading: widget.icon == null ? null : Icon(widget.icon, size: 20),
          title: Text(
            widget.label,
            style: AppTextStyles.body.copyWith(
              color: widget.accent
                  ? AppColors.secondary
                  : AppColors.textPrimary,
              fontWeight: widget.accent ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.items, required this.onHomeTap});

  final List<String> items;
  final VoidCallback onHomeTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      children: [
        InkWell(
          onTap: onHomeTap,
          child: Text(
            items.first,
            style: AppTextStyles.caption.copyWith(color: AppColors.info),
          ),
        ),
        for (final item in items.skip(1)) ...[
          const Icon(
            Icons.chevron_right,
            size: 14,
            color: AppColors.textSecondary,
          ),
          Text(item, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.trailing,
    this.padding,
  });

  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ??
          const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.lg,
            0,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title!, style: AppTextStyles.title),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: AppTextStyles.caption),
                      ],
                    ],
                  ),
                ),
                if (actionLabel != null && onAction != null)
                  TextButton(onPressed: onAction, child: Text(actionLabel!)),
                ?trailing,
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}

class _SeasonSaleHero extends StatelessWidget {
  const _SeasonSaleHero();

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      child: Container(
        constraints: const BoxConstraints(minHeight: 360),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.24),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _SaleBurstPainter())),
            Positioned(
              top: 34,
              left: 0,
              right: 0,
              child: Text(
                'ƯU ĐÃI CUỐI MÙA',
                textAlign: TextAlign.center,
                style: AppTextStyles.display.copyWith(
                  color: const Color(0xFF65F300),
                  fontSize: 30,
                  shadows: const [
                    Shadow(color: AppColors.info, offset: Offset(2, 2)),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 220,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                margin: const EdgeInsets.only(top: 32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 26,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'GIẢM ĐẾN',
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '50%',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.secondary,
                        fontSize: 72,
                        height: 0.9,
                      ),
                    ),
                    const Divider(thickness: 2),
                    Text(
                      'MUA 2 GIẢM THÊM',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '15%',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.secondary,
                        fontSize: 54,
                        height: 0.95,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.lg,
              child: Column(
                children: [
                  Text(
                    '18.6 - 5.7',
                    style: AppTextStyles.display.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                  Text(
                    '*Áp dụng điều kiện',
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaleBurstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.62, size.height * 0.56);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    for (var i = 0; i < 28; i++) {
      final startAngle = i * 0.23;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + size.width * 1.1 * (i.isEven ? 1 : -0.2),
          center.dy - size.height * 1.1 + i * 18,
        )
        ..lineTo(
          center.dx + size.width * 1.2,
          center.dy - size.height + i * 22 + startAngle * 20,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({required this.categories, required this.onTap});

  final List<NavigationCategoryModel> categories;
  final ValueChanged<NavigationCategoryModel> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _HoverLift(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              onTap: () => onTap(category),
              child: Container(
                width: 106,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _iconForCategory(category.name),
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      category.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _iconForCategory(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('gi') || normalized.contains('shoe')) {
      return Icons.directions_run;
    }
    if (normalized.contains('áo') || normalized.contains('ao')) {
      return Icons.checkroom;
    }
    if (normalized.contains('túi') || normalized.contains('tui')) {
      return Icons.backpack_outlined;
    }
    if (normalized.contains('quần') || normalized.contains('quan')) {
      return Icons.sports_martial_arts;
    }
    return Icons.sports_basketball;
  }
}

class _BrandGrid extends StatelessWidget {
  const _BrandGrid({required this.brands});

  final List<BrandModel> brands;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: brands.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.86,
      ),
      itemBuilder: (context, index) {
        final brand = brands[index];
        return _HoverLift(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (brand.banner.isNotEmpty || brand.logo.isNotEmpty)
                  Image.network(
                    brand.banner.isNotEmpty ? brand.banner : brand.logo,
                    fit: BoxFit.cover,
                    webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        'GIẢM 50%',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Mua ngay',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.controller});

  final CustomerHomeController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.recommendedProducts.isEmpty) {
      return const AppLoadingState(title: 'Đang tải sản phẩm');
    }
    if (controller.errorMessage != null &&
        controller.recommendedProducts.isEmpty) {
      return AppErrorState(
        title: 'Không tải được sản phẩm',
        message: controller.errorMessage!,
        onAction: controller.loadHome,
      );
    }
    if (controller.recommendedProducts.isEmpty) {
      return const AppEmptyState(
        title: 'Chưa có sản phẩm',
        message: 'Backend chưa trả về sản phẩm hiển thị.',
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.xl,
        childAspectRatio: 0.68,
      ),
      itemCount: controller.recommendedProducts.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: controller.recommendedProducts[index],
          index: index,
        );
      },
    );
  }
}

class _HoverLift extends StatefulWidget {
  const _HoverLift({required this.child});

  final Widget child;

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.025 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          child: widget.child,
        ),
      ),
    );
  }
}
