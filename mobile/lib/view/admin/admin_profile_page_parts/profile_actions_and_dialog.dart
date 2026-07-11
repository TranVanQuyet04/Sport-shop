part of '../admin_profile_page.dart';

class _ActionList extends StatelessWidget {
  const _ActionList({required this.onEditProfile, required this.onSecurity});

  final VoidCallback onEditProfile;
  final VoidCallback onSecurity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(AdminDesign.radius),
        boxShadow: AdminDesign.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.edit_outlined,
            title: 'Chỉnh sửa thông tin',
            subtitle: 'Cập nhật họ tên và số điện thoại',
            onTap: onEditProfile,
          ),
          const Divider(height: 1, indent: 68),
          _ActionTile(
            icon: Icons.security_outlined,
            title: 'Bảo mật tài khoản',
            subtitle: 'Thay đổi mật khẩu đăng nhập',
            onTap: onSecurity,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              AdminIconBadge(icon: icon, size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.subtitle.copyWith(
                        color: AdminColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
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

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}

class _ProfileUpdateData {
  const _ProfileUpdateData({required this.fullName, required this.phoneNumber});

  final String fullName;
  final String phoneNumber;
}
