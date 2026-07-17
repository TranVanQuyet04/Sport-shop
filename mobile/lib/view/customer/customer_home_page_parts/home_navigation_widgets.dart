part of '../customer_home_page.dart';

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
    final isPixel7 = AppDeviceProfiles.isPixel7WidthOrNarrower(context);

    return Material(
      color: AppColors.primary,
      child: SizedBox(
        height: isPixel7 ? 54 : 60,
        child: Row(
          children: [
            _NavIconButton(
              tooltip: 'Mở menu',
              icon: Icons.menu,
              onPressed: onOpenMenu,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: StrideXLogo(compact: isPixel7, inverse: true),
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
            if (!isPixel7)
              Container(
                width: 32,
                height: 24,
                margin: const EdgeInsets.only(right: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.star, color: Colors.yellow, size: 16),
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
    final enableHover = !AppDeviceProfiles.isPixel7WidthOrNarrower(context);
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: _hovered
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: IconButton(
        tooltip: widget.tooltip,
        onPressed: widget.onPressed,
        icon: Icon(widget.icon, color: Colors.white, size: 21),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      ),
    );

    if (!enableHover) {
      return content;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: content,
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({
    required this.categories,
    required this.onSelect,
    required this.onSelectCategory,
  });

  final List<NavigationCategoryModel> categories;
  final ValueChanged<String> onSelect;
  final ValueChanged<NavigationCategoryModel> onSelectCategory;

  @override
  Widget build(BuildContext context) {
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
              child: ListView(
                children: [
                  _DrawerEntry(
                    label: 'Xu hướng',
                    onTap: () => onSelect('Xu hướng'),
                  ),
                  const Divider(height: 1),
                  for (final category in categories) ...[
                    _DrawerCategoryNode(
                      category: category,
                      onSelect: onSelectCategory,
                    ),
                    const Divider(height: 1),
                  ],
                  _DrawerEntry(
                    label: 'Thương hiệu',
                    onTap: () => onSelect('Thương hiệu'),
                  ),
                  const Divider(height: 1),
                  _DrawerEntry(
                    label: 'Thể thao',
                    onTap: () => onSelect('Thể thao'),
                  ),
                  const Divider(height: 1),
                  _DrawerEntry(
                    label: 'Ưu đãi',
                    accent: true,
                    onTap: () => onSelect('Ưu đãi'),
                  ),
                  const Divider(height: 1),
                  _DrawerEntry(
                    label: 'Tìm kiếm',
                    onTap: () => onSelect('Tìm kiếm'),
                  ),
                  const Divider(height: 1),
                  _DrawerEntry(
                    label: 'Tra cứu đơn hàng',
                    icon: Icons.receipt_long_outlined,
                    onTap: () => onSelect('Tra cứu đơn hàng'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: StrideXLogo(compact: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerCategoryNode extends StatelessWidget {
  const _DrawerCategoryNode({
    required this.category,
    required this.onSelect,
    this.depth = 0,
  });

  final NavigationCategoryModel category;
  final ValueChanged<NavigationCategoryModel> onSelect;
  final int depth;

  @override
  Widget build(BuildContext context) {
    if (category.children.isEmpty) {
      return _DrawerCategoryLink(
        category: category,
        onSelect: onSelect,
        depth: depth,
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.only(
          left: AppSpacing.lg + depth * AppSpacing.md,
          right: AppSpacing.sm,
        ),
        childrenPadding: EdgeInsets.zero,
        title: Text(
          category.name,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        children: [
          _DrawerCategoryLink(
            category: category,
            onSelect: onSelect,
            depth: depth + 1,
            label: 'Xem tất cả ${category.name}',
            isAllLink: true,
          ),
          for (final child in category.children)
            _DrawerCategoryNode(
              category: child,
              onSelect: onSelect,
              depth: depth + 1,
            ),
        ],
      ),
    );
  }
}

class _DrawerCategoryLink extends StatelessWidget {
  const _DrawerCategoryLink({
    required this.category,
    required this.onSelect,
    required this.depth,
    this.label,
    this.isAllLink = false,
  });

  final NavigationCategoryModel category;
  final ValueChanged<NavigationCategoryModel> onSelect;
  final int depth;
  final String? label;
  final bool isAllLink;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isAllLink ? AppColors.surfaceMuted : AppColors.surface,
      child: ListTile(
        contentPadding: EdgeInsets.only(
          left: AppSpacing.lg + depth * AppSpacing.md,
          right: AppSpacing.lg,
        ),
        leading: isAllLink
            ? const Icon(Icons.grid_view_rounded, size: 18)
            : null,
        title: Text(
          label ?? category.name,
          style: AppTextStyles.body.copyWith(
            color: isAllLink ? AppColors.secondary : AppColors.textPrimary,
            fontWeight: isAllLink ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () => onSelect(category),
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
    final enableHover = !AppDeviceProfiles.isPixel7WidthOrNarrower(context);
    final content = Material(
      color: _hovered ? AppColors.surfaceMuted : AppColors.surface,
      child: ListTile(
        leading: widget.icon == null ? null : Icon(widget.icon, size: 20),
        title: Text(
          widget.label,
          style: AppTextStyles.body.copyWith(
            color: widget.accent ? AppColors.secondary : AppColors.textPrimary,
            fontWeight: widget.accent ? FontWeight.w900 : FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: widget.onTap,
      ),
    );

    if (!enableHover) {
      return content;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: content,
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
