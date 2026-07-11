part of '../admin_inventory_variants_page.dart';

class _StockSummary extends StatelessWidget {
  const _StockSummary({
    required this.title,
    required this.value,
    required this.subtitle,
    this.alert = false,
    this.dark = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final bool alert;
  final bool dark;

  @override
  Widget build(BuildContext context) => HoverLift(
    scale: 1.01,
    dy: -2,
    borderRadius: BorderRadius.circular(AppRadius.xl),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AdminColors.navy : AdminColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AdminDesign.cardShadow,
        border: alert
            ? const Border(
                left: BorderSide(color: AdminColors.accent, width: 4),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: dark ? Colors.white : AdminColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTextStyles.display.copyWith(
                fontSize: 42,
                color: dark ? Colors.white : AdminColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTextStyles.body.copyWith(
                color: dark ? Colors.white70 : AdminColors.primary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _InventoryChip extends StatelessWidget {
  const _InventoryChip({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(label),
    backgroundColor: active ? AdminColors.primary : AdminColors.surfaceMuted,
    labelStyle: TextStyle(
      color: active ? Colors.white : AdminColors.primary,
      fontWeight: FontWeight.w900,
    ),
  );
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({
    required this.variant,
    required this.onDecrease,
    required this.onIncrease,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductVariantModel variant;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final alert = variant.stockQuantity <= 5;
    return HoverLift(
      scale: 1.01,
      dy: -2,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AdminDesign.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AdminColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.directions_run,
                  color: alert ? AdminColors.accent : AdminColors.primary,
                  size: 48,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (alert)
                      const Chip(
                        label: Text('SẮP HẾT'),
                        backgroundColor: Color(0xFFFCE8EE),
                        labelStyle: TextStyle(color: AdminColors.accent),
                      ),
                    Text('SKU: ${variant.sku}', style: AppTextStyles.subtitle),
                    Text(
                      'Màu ${variant.color} • Size ${variant.size}',
                      style: AppTextStyles.body.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _QtyButton(label: '-', onTap: onDecrease),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: Text(
                            '${variant.stockQuantity}',
                            style: AppTextStyles.title,
                          ),
                        ),
                        _QtyButton(label: '+', onTap: onIncrease),
                        const Spacer(),
                        Text(
                          'Còn ${variant.stockQuantity} SP',
                          style: AppTextStyles.body.copyWith(
                            color: alert
                                ? AdminColors.accent
                                : AdminColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Sửa')),
                  PopupMenuItem(value: 'delete', child: Text('Xóa')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => HoverLift(
    interactive: true,
    scale: 1.06,
    dy: -1,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    child: Material(
      color: label == '+' ? AdminColors.primary : AdminColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: label == '+' ? Colors.white : AdminColors.primary,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
