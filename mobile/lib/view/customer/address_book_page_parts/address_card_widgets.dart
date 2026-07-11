part of '../address_book_page.dart';

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isBusy,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDelete,
  });

  final AddressModel address;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: address.isDefault ? AppColors.secondary : AppColors.border,
        ),
        boxShadow: SuperSportsTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.recipientName,
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        address.phoneNumber,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (address.isDefault) const _DefaultBadge(),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _AddressInfoRow(address: address.displayAddress),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _AddressActionButton(
                  label: 'Sửa',
                  icon: Icons.edit_outlined,
                  onPressed: isBusy ? null : onEdit,
                ),
                const SizedBox(width: AppSpacing.sm),
                _AddressActionButton(
                  label: 'Xóa',
                  icon: Icons.delete_outline,
                  foregroundColor: AppColors.error,
                  onPressed: isBusy ? null : onDelete,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: isBusy || address.isDefault ? null : onSetDefault,
                  icon: Icon(
                    address.isDefault
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 18,
                  ),
                  label: const Text('Mặc định'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.secondarySoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          'Mặc định',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _AddressInfoRow extends StatelessWidget {
  const _AddressInfoRow({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: AppColors.textSecondary,
          size: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            address,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _AddressActionButton extends StatelessWidget {
  const _AddressActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? AppColors.primary;
    return SizedBox(
      height: 44,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          minimumSize: const Size(44, 44),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}
