import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/admin_design_system.dart';

// ── DATE FILTER ROW ─────────────────────────────────────────────────────────
class DateFilterRow extends StatelessWidget {
  const DateFilterRow({
    super.key,
    required this.selectedRange,
    required this.selectedPreset,
    required this.onQuickSelect,
    required this.onTap,
  });

  final DateTimeRange? selectedRange;
  final String selectedPreset;
  final void Function(String) onQuickSelect;
  final VoidCallback onTap;

  String _formatSelection(DateTimeRange range) {
    switch (selectedPreset) {
      case 'day':
        return 'Ngày ${DateFormat('dd/MM/yyyy').format(range.start)}';
      case 'week':
        final week = ((range.start.day - 1) ~/ 7) + 1;
        return 'Tuần $week · ${DateFormat('dd/MM').format(range.start)} – ${DateFormat('dd/MM/yyyy').format(range.end)}';
      case 'month':
        return 'Tháng ${range.start.month}/${range.start.year}';
      case 'quarter':
        final quarter = ((range.start.month - 1) ~/ 3) + 1;
        return 'Quý $quarter/${range.start.year}';
      case 'year':
        return 'Năm ${range.start.year}';
      default:
        return '${DateFormat('dd/MM/yyyy').format(range.start)} – ${DateFormat('dd/MM/yyyy').format(range.end)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 48,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (final filter in const [
                  ('Ngày', 'day'),
                  ('Tuần', 'week'),
                  ('Tháng', 'month'),
                  ('Quý', 'quarter'),
                  ('Năm', 'year'),
                  ('Tùy chỉnh', 'custom'),
                ]) ...[
                  _QuickFilterChip(
                    label: filter.$1,
                    value: filter.$2,
                    selected: selectedPreset == filter.$2,
                    onSelect: onQuickSelect,
                  ),
                  if (filter.$2 != 'custom')
                    const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Material(
          color: AdminColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            mouseCursor: SystemMouseCursors.click,
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdminColors.inputBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.date_range_outlined,
                    size: 18,
                    color: Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedRange != null
                          ? _formatSelection(selectedRange!)
                          : 'Chọn khoảng ngày',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
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
      ],
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  const _QuickFilterChip({
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
    return Material(
      color: selected ? const Color(0xFF061B33) : AdminColors.primarySoft,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        mouseCursor: SystemMouseCursors.click,
        onTap: () => onSelect(value),
        child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFFD97706).withValues(alpha: 0.65)
                  : AdminColors.primary.withValues(alpha: 0.2),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? Colors.white : AdminColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
