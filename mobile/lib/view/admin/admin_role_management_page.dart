import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../model/admin/admin_lookup_model.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminRoleManagementPage extends StatefulWidget {
  const AdminRoleManagementPage({super.key});

  @override
  State<AdminRoleManagementPage> createState() =>
      _AdminRoleManagementPageState();
}

class _AdminRoleManagementPageState extends State<AdminRoleManagementPage> {
  static const List<String> _roles = [
    'ADMIN',
    'SHOP_STAFF',
    'DELIVERY_STAFF',
    'CUSTOMER',
  ];

  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadUsers();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Map<String, int> get _roleCounts {
    final counts = {for (final role in _roles) role: 0};
    for (final user in _controller.users) {
      final role = _normalizeRole(user.roleName);
      counts[role] = (counts[role] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> _openRoleUpdate() async {
    final result = await showDialog<_RoleUpdateResult>(
      context: context,
      builder: (_) => _RoleUpdateDialog(users: _controller.users),
    );
    if (result == null) {
      return;
    }

    final user = result.user;
    final success = await _controller.saveUser(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      password: '',
      confirmPassword: '',
      roleName: result.roleName,
      status: user.status,
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã cập nhật vai trò cho ${user.fullName}.'
              : (_controller.errorMessage ?? 'Chưa cập nhật được vai trò.'),
        ),
      ),
    );
  }

  static String _normalizeRole(String roleName) {
    final value = roleName.toUpperCase();
    if (value == 'SHIPPER') {
      return 'DELIVERY_STAFF';
    }
    if (value == 'STAFF') {
      return 'SHOP_STAFF';
    }
    if (_roles.contains(value)) {
      return value;
    }
    return 'CUSTOMER';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Quản lý quyền hạn'),
        actions: [
          IconButton(
            onPressed: _controller.isLoading ? null : _controller.loadUsers,
            icon: const Icon(Icons.refresh),
          ),
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _controller.loadUsers,
        child: _buildBody(),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.users.isEmpty) {
      return const AppLoadingState(title: 'Đang tải quyền hạn');
    }
    if (_controller.errorMessage != null && _controller.users.isEmpty) {
      return AppErrorState(
        title: 'Không tải được quyền hạn',
        message: _controller.errorMessage!,
        onAction: _controller.loadUsers,
      );
    }

    final roleCounts = _roleCounts;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (_controller.errorMessage != null) ...[
          _RoleDemoBanner(
            message: _controller.errorMessage!,
            onRefresh: _controller.loadUsers,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Row(
          children: [
            const Expanded(
              child: AppTextField(
                label: 'Tìm kiếm',
                prefixIcon: Icons.search,
                hintText: 'Tìm kiếm vai trò hoặc người dùng...',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _QuickUpdateButton(onTap: _openRoleUpdate),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: Text(
                'DANH SÁCH VAI TRÒ (${_roles.length})',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            GestureDetector(
              onTap: _openRoleUpdate,
              child: const Text(
                'Cập nhật nhanh',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _RoleTile(
          icon: Icons.admin_panel_settings_outlined,
          name: 'ADMIN',
          members: '${roleCounts['ADMIN'] ?? 0} thành viên',
          active: true,
          onTap: _openRoleUpdate,
        ),
        _RoleTile(
          icon: Icons.storefront_outlined,
          name: 'SHOP_STAFF',
          members: '${roleCounts['SHOP_STAFF'] ?? 0} thành viên',
          onTap: _openRoleUpdate,
        ),
        _RoleTile(
          icon: Icons.local_shipping_outlined,
          name: 'DELIVERY_STAFF',
          members: '${roleCounts['DELIVERY_STAFF'] ?? 0} thành viên',
          onTap: _openRoleUpdate,
        ),
        _RoleTile(
          icon: Icons.person_outline,
          name: 'CUSTOMER',
          members: '${roleCounts['CUSTOMER'] ?? 0} thành viên',
          onTap: _openRoleUpdate,
        ),
        const SizedBox(height: AppSpacing.xl),
        const _SecurityNote(),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Ghi chú: backend chưa có RoleController riêng, nên màn này cập nhật role trực tiếp trên user qua API admin/users.',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _RoleDemoBanner extends StatelessWidget {
  const _RoleDemoBanner({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.info),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.caption.copyWith(color: AppColors.info),
              ),
            ),
            TextButton(onPressed: onRefresh, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

class _RoleUpdateResult {
  const _RoleUpdateResult({required this.user, required this.roleName});

  final AdminUserModel user;
  final String roleName;
}

class _RoleUpdateDialog extends StatefulWidget {
  const _RoleUpdateDialog({required this.users});

  final List<AdminUserModel> users;

  @override
  State<_RoleUpdateDialog> createState() => _RoleUpdateDialogState();
}

class _RoleUpdateDialogState extends State<_RoleUpdateDialog> {
  static const List<String> _roles = [
    'ADMIN',
    'SHOP_STAFF',
    'DELIVERY_STAFF',
    'CUSTOMER',
  ];

  AdminUserModel? _selectedUser;
  String _selectedRole = 'CUSTOMER';

  @override
  void initState() {
    super.initState();
    if (widget.users.isNotEmpty) {
      _selectedUser = widget.users.first;
      _selectedRole = _normalizeRole(widget.users.first.roleName);
    }
  }

  static String _normalizeRole(String roleName) {
    final value = roleName.toUpperCase();
    if (_roles.contains(value)) {
      return value;
    }
    if (value == 'SHIPPER') {
      return 'DELIVERY_STAFF';
    }
    if (value == 'STAFF') {
      return 'SHOP_STAFF';
    }
    return 'CUSTOMER';
  }

  void _submit() {
    final user = _selectedUser;
    if (user == null) {
      return;
    }
    Navigator.pop(
      context,
      _RoleUpdateResult(user: user, roleName: _selectedRole),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cập nhật vai trò'),
      content: widget.users.isEmpty
          ? const Text('Chưa có người dùng để cập nhật.')
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedUser?.id,
                  decoration: const InputDecoration(labelText: 'Người dùng'),
                  items: widget.users
                      .map(
                        (user) => DropdownMenuItem(
                          value: user.id,
                          child: Text(
                            '${user.fullName} • ${user.roleName}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (userId) {
                    final user = widget.users.firstWhere(
                      (item) => item.id == userId,
                    );
                    setState(() {
                      _selectedUser = user;
                      _selectedRole = _normalizeRole(user.roleName);
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Vai trò mới'),
                  items: _roles
                      .map(
                        (role) =>
                            DropdownMenuItem(value: role, child: Text(role)),
                      )
                      .toList(),
                  onChanged: (role) {
                    if (role != null) {
                      setState(() => _selectedRole = role);
                    }
                  },
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: widget.users.isEmpty ? null : _submit,
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class _QuickUpdateButton extends StatelessWidget {
  const _QuickUpdateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppRadius.md),
    child: Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Icon(Icons.edit, color: Colors.white),
    ),
  );
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.icon,
    required this.name,
    required this.members,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String name;
  final String members;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        minVerticalPadding: AppSpacing.lg,
        leading: CircleAvatar(
          radius: 34,
          backgroundColor: active ? AppColors.primary : AppColors.surfaceMuted,
          foregroundColor: active ? Colors.white : AppColors.primary,
          child: Icon(icon),
        ),
        title: Text(name, style: AppTextStyles.title),
        subtitle: Text(members, style: AppTextStyles.body),
        trailing: const Icon(Icons.edit),
      ),
    ),
  );
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFFFE2E7),
      border: const Border(
        left: BorderSide(color: AppColors.secondary, width: 4),
      ),
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Lưu ý bảo mật\nViệc thay đổi quyền ADMIN có thể ảnh hưởng đến khả năng truy cập hệ thống của quản trị viên.',
              style: AppTextStyles.body.copyWith(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    ),
  );
}
