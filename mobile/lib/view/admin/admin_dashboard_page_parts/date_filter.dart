// ──────────────────────────────────────────────────────────────────────────────
//  Date Filter (Admin Dashboard part file)
// ──────────────────────────────────────────────────────────────────────────────
part of '../admin_dashboard_page.dart';

class _DateFilter extends StatelessWidget {
  const _DateFilter({
    required this.selectedRange,
    required this.selectedQuickRange,
    required this.onQuickSelect,
    required this.onTap,
  });

  final DateTimeRange? selectedRange;
  final String? selectedQuickRange;
  final void Function(String) onQuickSelect;
  final VoidCallback onTap;

  String _formatRange(DateTimeRange range) =>
      '${DateFormat('dd/MM/yyyy').format(range.start)} – ${DateFormat('dd/MM/yyyy').format(range.end)}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AdminColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdminColors.inputBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.date_range_outlined,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedRange != null
                          ? _formatRange(selectedRange!)
                          : 'Chọn khoảng ngày',
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _QuickChip(
                label: 'Hôm nay',
                value: 'today',
                selected: selectedQuickRange == 'today',
                onSelect: onQuickSelect,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuickChip(
                label: '7 ngày',
                value: '7d',
                selected: selectedQuickRange == '7d',
                onSelect: onQuickSelect,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuickChip(
                label: '30 ngày',
                value: '30d',
                selected: selectedQuickRange == '30d',
                onSelect: onQuickSelect,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final String value;
  final bool selected;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Xem dữ liệu $label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelect(value),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.center,
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AdminColors.primary : AdminColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AdminColors.primary : AdminColors.inputBorder,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AdminColors.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: selected ? Colors.white : AdminColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
