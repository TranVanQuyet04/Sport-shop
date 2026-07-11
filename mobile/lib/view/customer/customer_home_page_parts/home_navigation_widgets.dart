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
              child: StrideXLogo(compact: false),
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
