import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../model/admin/system_setting_model.dart';
import '../../presenter/admin/admin_setting_presenter.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

class AdminSystemSettingsPage extends StatefulWidget {
  const AdminSystemSettingsPage({super.key});

  @override
  State<AdminSystemSettingsPage> createState() =>
      _AdminSystemSettingsPageState();
}

class _AdminSystemSettingsPageState extends State<AdminSystemSettingsPage> {
  late final AdminSettingPresenter _presenter = AdminSettingPresenter(
    adminSettingRepository: AppDependencies.instance.adminSettingRepository,
  );

  @override
  void initState() {
    super.initState();
    _presenter.addListener(_onPresenterChanged);
    _presenter.loadSettings();
  }

  @override
  void dispose() {
    _presenter
      ..removeListener(_onPresenterChanged)
      ..dispose();
    super.dispose();
  }

  void _onPresenterChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          104,
        ),
        children: [
          const AdminPageHeader(
            title: 'Cài đặt hệ thống',
            subtitle: 'Quản lý tài khoản và các tùy chọn vận hành của StrideX.',
            icon: Icons.tune_rounded,
          ),
          const SizedBox(height: AppSpacing.xl),
          _SettingsBlock(
            title: 'Tài khoản',
            subtitle: 'Thông tin và bảo mật đăng nhập',
            children: [
              _SettingTile(
                icon: Icons.person_outline_rounded,
                title: 'Thông tin cá nhân',
                subtitle: 'Xem và cập nhật hồ sơ của bạn',
                onTap: () => context.push(AppRoutes.adminProfile),
              ),
              _SettingTile(
                icon: Icons.lock_outline_rounded,
                title: 'Đổi mật khẩu',
                subtitle: 'Cập nhật mật khẩu đăng nhập an toàn',
                onTap: () => context.push(AppRoutes.adminChangePassword),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsBlock(
            title: 'Quản lý cửa hàng',
            subtitle: 'Dữ liệu và nội dung vận hành StrideX',
            children: [
              _SettingTile(
                icon: Icons.category_outlined,
                title: 'Danh mục',
                subtitle: 'Cấu trúc phân loại sản phẩm StrideX',
                onTap: () => context.push(AppRoutes.adminCategories),
              ),
              _SettingTile(
                icon: Icons.verified_outlined,
                title: 'Thương hiệu',
                subtitle: 'Logo và thông tin thương hiệu',
                onTap: () => context.push(AppRoutes.adminBrands),
              ),
              _SettingTile(
                icon: Icons.sports_soccer_outlined,
                title: 'Môn thể thao',
                subtitle: 'Nhóm thể thao dùng cho điều hướng',
                onTap: () => context.push(AppRoutes.adminSports),
              ),
              _SettingTile(
                icon: Icons.collections_bookmark_outlined,
                title: 'Bộ sưu tập',
                subtitle: 'Chiến dịch, mùa bán hàng và nhóm nổi bật',
                onTap: () => context.push(AppRoutes.adminCollections),
              ),
              _SettingTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Phòng chat',
                subtitle: 'Theo dõi hội thoại hỗ trợ khách hàng',
                onTap: () => context.push(AppRoutes.adminChatRooms),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsBlock(
            title: 'Hệ thống & vận hành',
            subtitle: 'Thiết lập cửa hàng và thông báo',
            children: [
              _SettingTile(
                icon: Icons.storefront_outlined,
                title: 'Cấu hình Shop',
                subtitle: 'Thông tin cửa hàng, hotline, địa chỉ',
                onTap: () => _showSettingSheet(
                  initialKey: 'shop.name',
                  initialDescription: 'Tên hiển thị của cửa hàng.',
                ),
              ),
              _NotificationTile(
                value: _presenter.notificationsEnabled,
                isSaving: _presenter.isSaving || _presenter.isLoading,
                onChanged: _updateNotifications,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsBlock(
            title: 'Cấu hình backend',
            subtitle: 'CRUD trực tiếp các key từ /api/admin/settings',
            children: [
              if (_presenter.isLoading)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_presenter.settings.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Chưa có cài đặt nào. Hãy thêm key đầu tiên.',
                    style: AppTextStyles.body.copyWith(
                      color: AdminColors.textSecondary,
                    ),
                  ),
                )
              else
                for (final setting in _presenter.settings)
                  _SettingValueTile(
                    setting: setting,
                    isSaving: _presenter.isSaving,
                    onEdit: () => _showSettingSheet(setting: setting),
                    onDelete:
                        setting.key == AdminSettingPresenter.notificationsKey
                        ? null
                        : () => _confirmDeleteSetting(setting),
                  ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppButton(
                  label: 'Thêm cài đặt',
                  icon: Icons.add_rounded,
                  variant: AppButtonVariant.outline,
                  onPressed: _presenter.isSaving ? null : _showSettingSheet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _LogoutTile(
            onPressed: () async {
              await AppDependencies.instance.authRepository.logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 4),
    );
  }

  Future<void> _updateNotifications(bool value) async {
    final success = await _presenter.updateNotifications(value);
    if (!mounted) {
      return;
    }
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _presenter.errorMessage ?? 'Không thể cập nhật cài đặt thông báo.',
          ),
        ),
      );
    }
  }

  Future<void> _showSettingSheet({
    SystemSettingModel? setting,
    String? initialKey,
    String? initialDescription,
  }) async {
    final keyController = TextEditingController(
      text: setting?.key ?? initialKey ?? '',
    );
    final valueController = TextEditingController(text: setting?.value ?? '');
    final descriptionController = TextEditingController(
      text: setting?.description ?? initialDescription ?? '',
    );
    var hasSubmitted = false;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
              Future<void> save() async {
                setSheetState(() => hasSubmitted = true);
                if (keyController.text.trim().isEmpty) {
                  return;
                }
                final success = await _presenter.saveSetting(
                  key: keyController.text,
                  value: valueController.text,
                  description: descriptionController.text,
                );
                if (!context.mounted) {
                  return;
                }
                if (success) {
                  Navigator.of(context).pop();
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _presenter.errorMessage ?? 'Không thể lưu cài đặt.',
                    ),
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            setting == null
                                ? 'Thêm cài đặt'
                                : 'Cập nhật cài đặt',
                            style: AppTextStyles.title,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Đóng',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Key',
                      hintText: 'VD: shop.hotline',
                      controller: keyController,
                      enabled: setting == null,
                      prefixIcon: Icons.key_rounded,
                      errorText:
                          hasSubmitted && keyController.text.trim().isEmpty
                          ? 'Key là bắt buộc.'
                          : null,
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Giá trị',
                      controller: valueController,
                      prefixIcon: Icons.edit_note_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Mô tả',
                      controller: descriptionController,
                      prefixIcon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'Lưu cài đặt',
                      icon: Icons.save_outlined,
                      isLoading: _presenter.isSaving,
                      onPressed: save,
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      keyController.dispose();
      valueController.dispose();
      descriptionController.dispose();
    }
  }

  Future<void> _confirmDeleteSetting(SystemSettingModel setting) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa cài đặt?'),
          content: Text(setting.key),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    final success = await _presenter.deleteSetting(setting.key);
    if (!mounted || success) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_presenter.errorMessage ?? 'Không thể xóa cài đặt.'),
      ),
    );
  }
}

class _SettingsBlock extends StatelessWidget {
  const _SettingsBlock({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.title.copyWith(
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
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(AdminDesign.radius),
            boxShadow: AdminDesign.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1)
                  const Divider(
                    height: 1,
                    indent: 68,
                    endIndent: AppSpacing.lg,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
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
        splashColor: AdminColors.primary.withValues(alpha: 0.08),
        highlightColor: AdminColors.primary.withValues(alpha: 0.03),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
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

class _SettingValueTile extends StatelessWidget {
  const _SettingValueTile({
    required this.setting,
    required this.isSaving,
    required this.onEdit,
    required this.onDelete,
  });

  final SystemSettingModel setting;
  final bool isSaving;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminIconBadge(icon: Icons.tune_rounded, size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  setting.key,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AdminColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  setting.value.isEmpty ? '(trống)' : setting.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AdminColors.textPrimary,
                  ),
                ),
                if (setting.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    setting.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sửa',
            onPressed: isSaving ? null : onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Xóa',
            onPressed: isSaving ? null : onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.value,
    required this.isSaving,
    required this.onChanged,
  });

  final bool value;
  final bool isSaving;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          const AdminIconBadge(
            icon: Icons.notifications_none_rounded,
            size: 40,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cài đặt thông báo',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AdminColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Nhận cập nhật quan trọng từ hệ thống',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AdminColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Switch.adaptive(
            value: value,
            activeTrackColor: AdminColors.primary,
            onChanged: isSaving ? null : onChanged,
          ),
        ],
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        splashColor: const Color(0xFFDC2626).withValues(alpha: 0.10),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 18,
          ),
          child: Row(
            children: [
              const AdminIconBadge(
                icon: Icons.logout_rounded,
                color: Color(0xFFDC2626),
                backgroundColor: Color(0xFFFFE4E6),
                size: 42,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Đăng xuất',
                  style: AppTextStyles.subtitle.copyWith(
                    color: const Color(0xFFDC2626),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
