part of 'revenue_period_picker.dart';

class _PickerHeader extends StatelessWidget {
  const _PickerHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AdminColors.primarySoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AdminColors.primary, size: 22),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.subtitle),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AdminColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _YearDropdown extends StatelessWidget {
  const _YearDropdown({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final years = List.generate(
      now.year - RevenuePeriodPicker.earliestYear + 1,
      (index) => now.year - index,
    );
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Năm',
        prefixIcon: Icon(Icons.event_outlined),
      ),
      items: years
          .map((year) => DropdownMenuItem(value: year, child: Text('$year')))
          .toList(),
      onChanged: (year) {
        if (year != null) onChanged(year);
      },
    );
  }
}

class _GridPeriodButton extends StatelessWidget {
  const _GridPeriodButton({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: selected ? Colors.white : AdminColors.primary,
          backgroundColor: selected ? AdminColors.primary : null,
          disabledForegroundColor: AdminColors.textSecondary.withValues(
            alpha: 0.48,
          ),
          disabledBackgroundColor: AdminColors.surfaceMuted.withValues(
            alpha: 0.55,
          ),
          side: BorderSide(
            color: !enabled
                ? AdminColors.inputBorder.withValues(alpha: 0.45)
                : selected
                ? AdminColors.primary
                : AdminColors.inputBorder,
          ),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

class _PeriodOptionTile extends StatelessWidget {
  const _PeriodOptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AdminColors.primarySoft : AdminColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AdminColors.primary : AdminColors.inputBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.date_range_outlined,
                color: enabled
                    ? AdminColors.primary
                    : AdminColors.textSecondary.withValues(alpha: 0.45),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.subtitle.copyWith(
                        color: enabled
                            ? AdminColors.textPrimary
                            : AdminColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      enabled ? subtitle : 'Chưa đến thời gian này',
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (enabled)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AdminColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
