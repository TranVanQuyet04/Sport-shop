part of '../admin_profile_page.dart';

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final ProfileModel? profile;

  @override
  Widget build(BuildContext context) {
    final fullName = profile?.fullName.trim() ?? '';
    final initial = fullName.isEmpty ? 'A' : fullName[0].toUpperCase();

    return Column(
      children: [
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AdminColors.primary,
            border: Border.all(color: Colors.white, width: 5),
            boxShadow: [
              BoxShadow(
                color: AdminColors.primary.withValues(alpha: 0.20),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: AppTextStyles.display.copyWith(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          fullName.isEmpty ? 'ADMIN' : fullName.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTextStyles.title.copyWith(
            color: AdminColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          profile?.email.isNotEmpty == true
              ? profile!.email
              : 'Chưa cập nhật email',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AdminColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          profile?.phoneNumber.isNotEmpty == true
              ? profile!.phoneNumber
              : 'Chưa cập nhật số điện thoại',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AdminColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _AccountStatusCard extends StatelessWidget {
  const _AccountStatusCard({required this.profile});

  final ProfileModel? profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AdminDesign.cardShadow,
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'User ID',
            value: Text(
              profile?.id.isNotEmpty == true ? profile!.id : '-',
              style: AppTextStyles.body.copyWith(
                color: AdminColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Divider(height: AppSpacing.xxl),
          _InfoRow(
            label: 'Quyền hạn',
            value: const _StatusTag(
              label: 'ADMIN',
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
          const Divider(height: AppSpacing.xxl),
          _InfoRow(
            label: 'Trạng thái',
            value: _StatusTag(
              label: profile?.status == false ? 'Tạm khóa' : 'Hoạt động',
              backgroundColor: profile?.status == false
                  ? AdminColors.dangerSoft
                  : AdminColors.successSoft,
              foregroundColor: profile?.status == false
                  ? AdminColors.danger
                  : AdminColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AdminColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        value,
      ],
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
