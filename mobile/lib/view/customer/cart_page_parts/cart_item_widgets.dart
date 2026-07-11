part of '../cart_page.dart';

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.totalItems});

  final int totalItems;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.textInverse,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giỏ hàng',
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$totalItems sản phẩm đang chờ thanh toán',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textInverse.withValues(alpha: 0.78),
                    ),
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

class _InlineCartError extends StatelessWidget {
  const _InlineCartError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({
    required this.item,
    required this.isBusy,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final CartItemModel item;
  final bool isBusy;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final unitPriceText = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(item.price);
    final subtotalText = NumberFormat.decimalPattern(
      'vi_VN',
    ).format(item.subTotal);
    final canIncrease = item.maxStock > 0 && item.quantity < item.maxStock;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductImage(imageUrl: item.imageUrl),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              style: AppTextStyles.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Xóa sản phẩm',
                            visualDensity: VisualDensity.compact,
                            onPressed: isBusy ? null : onRemove,
                            icon: const Icon(Icons.delete_outline),
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          if (item.size.isNotEmpty)
                            _InfoChip(label: 'Size ${item.size}'),
                          if (item.color.isNotEmpty)
                            _InfoChip(label: item.color),
                          _InfoChip(
                            label: item.maxStock > 0
                                ? 'Kho ${item.maxStock}'
                                : 'Hết hàng',
                            tone: item.maxStock > 0
                                ? _InfoChipTone.neutral
                                : _InfoChipTone.warning,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  _PriceLine(label: 'Đơn giá', value: '$unitPriceTextđ'),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Số lượng', style: AppTextStyles.caption),
                      ),
                      _QuantityStepper(
                        quantity: item.quantity,
                        isBusy: isBusy,
                        canIncrease: canIncrease,
                        onDecrease: onDecrease,
                        onIncrease: onIncrease,
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.xl),
                  _PriceLine(
                    label: 'Thành tiền',
                    value: '$subtotalTextđ',
                    isEmphasized: true,
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

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 104,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? const Icon(
              Icons.directions_run,
              color: AppColors.secondary,
              size: 42,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.directions_run,
                  color: AppColors.secondary,
                  size: 42,
                );
              },
            ),
    );
  }
}

enum _InfoChipTone { neutral, warning }

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, this.tone = _InfoChipTone.neutral});

  final String label;
  final _InfoChipTone tone;

  @override
  Widget build(BuildContext context) {
    final isWarning = tone == _InfoChipTone.warning;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isWarning
            ? AppColors.warning.withValues(alpha: 0.12)
            : AppColors.secondarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isWarning ? AppColors.warning : AppColors.secondary,
          ),
        ),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final String value;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.caption),
        const Spacer(),
        Text(
          value,
          style: (isEmphasized ? AppTextStyles.subtitle : AppTextStyles.body)
              .copyWith(
                color: isEmphasized ? AppColors.primary : AppColors.textPrimary,
              ),
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.isBusy,
    required this.canIncrease,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final bool isBusy;
  final bool canIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderStrong),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Giảm số lượng',
            onPressed: isBusy ? null : onDecrease,
            icon: const Icon(Icons.remove, size: 18),
          ),
          SizedBox(
            width: 34,
            child: Center(
              child: Text('$quantity', style: AppTextStyles.subtitle),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: canIncrease ? 'Tăng số lượng' : 'Đã đạt số lượng tồn kho',
            onPressed: isBusy || !canIncrease ? null : onIncrease,
            icon: const Icon(Icons.add, size: 18),
          ),
        ],
      ),
    );
  }
}
