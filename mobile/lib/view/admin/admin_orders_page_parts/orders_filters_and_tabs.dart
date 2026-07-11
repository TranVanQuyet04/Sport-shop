part of '../admin_orders_page.dart';

class _OrderEmptyPresentation {
  const _OrderEmptyPresentation({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}

abstract final class _OrderPalette {
  static const Color slate = Color(0xFF64748B);
  static const Color productSurface = Color(0xFFF1F5F9);
  static const Color pendingText = Color(0xFF9A3412);
  static const Color pendingSurface = Color(0xFFFFF1E6);
  static const Color infoText = Color(0xFF1D4ED8);
  static const Color infoSurface = Color(0xFFDBEAFE);
  static const Color successText = Color(0xFF166534);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color errorText = Color(0xFF991B1B);
  static const Color errorSurface = Color(0xFFFEE2E2);
}

class _OrderSearchField extends StatelessWidget {
  const _OrderSearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      padding: EdgeInsets.zero,
      hoverEnabled: false,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Tìm mã đơn, khách hàng, số điện thoại, sản phẩm...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Xóa tìm kiếm',
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: AdminColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AdminColors.primary, width: 1),
          ),
        ),
      ),
    );
  }
}

class _OrderTabs extends StatelessWidget {
  const _OrderTabs({required this.selectedStatus, required this.onChanged});

  final OrderStatus? selectedStatus;
  final ValueChanged<OrderStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    const tabs = [
      _OrderTabItem(label: 'Tất cả'),
      _OrderTabItem(label: 'Chờ xác nhận', status: OrderStatus.pending),
      _OrderTabItem(label: 'Đã xác nhận', status: OrderStatus.confirmed),
      _OrderTabItem(label: 'Đang đóng gói', status: OrderStatus.packing),
      _OrderTabItem(label: 'Đang giao', status: OrderStatus.shipped),
      _OrderTabItem(label: 'Chờ hoàn tất', status: OrderStatus.delivered),
      _OrderTabItem(label: 'Hoàn thành', status: OrderStatus.completed),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final selected = selectedStatus == tab.status;
          return ChoiceChip(
            label: Text(tab.label),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => onChanged(tab.status),
            selectedColor: AdminColors.primary,
            backgroundColor: AdminColors.surfaceMuted,
            side: BorderSide.none,
            elevation: selected ? 3 : 0,
            shadowColor: AdminColors.primary.withValues(alpha: 0.22),
            pressElevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            labelStyle: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : AdminColors.textSecondary,
            ),
          );
        },
      ),
    );
  }
}

class _OrderTabItem {
  const _OrderTabItem({required this.label, this.status});

  final String label;
  final OrderStatus? status;
}

class _StaggeredOrderCard extends StatefulWidget {
  const _StaggeredOrderCard({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<_StaggeredOrderCard> createState() => _StaggeredOrderCardState();
}

class _StaggeredOrderCardState extends State<_StaggeredOrderCard> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 55 * widget.index.clamp(0, 8));
    _timer = Timer(delay, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: widget.child,
        ),
      ),
    );
  }
}
