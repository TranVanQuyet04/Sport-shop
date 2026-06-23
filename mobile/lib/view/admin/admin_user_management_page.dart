import 'package:flutter/material.dart';

import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/auth/role_mapper.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'ALL';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_controller.loadUsers(), _controller.loadRoles()]);
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  Future<void> _openUserForm([AdminUserModel? user]) async {
    final result = await showDialog<_UserFormResult>(
      context: context,
      builder: (_) => _UserFormDialog(user: user, roles: _controller.roles),
    );
    if (result == null) {
      return;
    }

    final success = await _controller.saveUser(
      id: user?.id,
      fullName: result.fullName,
      email: result.email,
      phoneNumber: result.phoneNumber,
      password: result.password,
      confirmPassword: result.confirmPassword,
      roleName: result.roleName,
      status: result.status,
    );
    if (!mounted) {
      return;
    }
    _showResult(
      success,
      user == null ? 'Đã thêm người dùng.' : 'Đã cập nhật người dùng.',
    );
  }

  Future<void> _deleteUser(AdminUserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa người dùng?'),
        content: Text('Bạn có chắc muốn xóa "${user.fullName}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    final success = await _controller.deleteUser(user.id);
    if (!mounted) {
      return;
    }
    _showResult(success, 'Đã xóa người dùng.');
  }

  void _showResult(bool success, String successMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? successMessage
              : (_controller.errorMessage ?? 'Thao tác chưa thành công.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Quản lý người dùng'),
      actions: [
        IconButton(
          onPressed: _controller.isLoading ? null : _loadData,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: RefreshIndicator(onRefresh: _loadData, child: _buildBody()),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      onPressed: _controller.isSubmitting ? null : () => _openUserForm(),
      child: _controller.isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.person_add_alt),
    ),
    bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
  );

  Widget _buildBody() {
    if (_controller.isLoading && _controller.users.isEmpty) {
      return const AppLoadingState(title: 'Đang tải người dùng');
    }
    if (_controller.errorMessage != null && _controller.users.isEmpty) {
      return AppErrorState(
        title: 'Không tải được người dùng',
        message: _controller.errorMessage!,
        onAction: _controller.loadUsers,
      );
    }
    if (_controller.users.isEmpty) {
      return PremiumEmptyState(
        icon: Icons.manage_accounts_outlined,
        title: 'Chưa có người dùng',
        message: 'Tạo tài khoản để phân quyền Admin, Shipper hoặc khách hàng.',
        actionLabel: 'Thêm mới ngay',
        onAction: () => _openUserForm(),
      );
    }
    final visibleUsers = _visibleUsers;
    final activeUsers = _controller.users.where((user) => user.status).length;
    final adminUsers = _controller.users
        .where((user) => RoleMapper.normalize(user.roleName) == 'ADMIN')
        .length;
    return AbsolutePersistentLayout(
      title: 'Quản lý người dùng',
      subtitle: 'Kiểm soát tài khoản, vai trò và trạng thái truy cập hệ thống.',
      icon: Icons.manage_accounts_outlined,
      trailing: _UserCountBadge(count: _controller.users.length),
      filterAndSearchZone: _UserToolbar(
        controller: _searchController,
        selectedRole: _selectedRole,
        onSearchChanged: (_) => setState(() {}),
        onRoleChanged: (role) => setState(() => _selectedRole = role),
        totalUsers: _controller.users.length,
        activeUsers: activeUsers,
        adminUsers: adminUsers,
      ),
      dynamicContent: ListView.separated(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 0),
        itemCount: visibleUsers.isEmpty ? 1 : visibleUsers.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          if (visibleUsers.isEmpty) {
            return PremiumEmptyState(
              icon: Icons.search_off_rounded,
              title: 'Không tìm thấy người dùng',
              message: 'Hãy thử đổi từ khóa hoặc bỏ bộ lọc vai trò hiện tại.',
              actionLabel: 'Xóa bộ lọc',
              onAction: () {
                _searchController.clear();
                setState(() => _selectedRole = 'ALL');
              },
            );
          }
          final user = visibleUsers[index];
          return _UserCard(
            user: user,
            onEdit: () => _openUserForm(user),
            onDelete: () => _deleteUser(user),
          );
        },
      ),
    );
  }

  List<AdminUserModel> get _visibleUsers {
    final query = _searchController.text.trim().toLowerCase();
    return _controller.users.where((user) {
      final normalizedRole = RoleMapper.normalize(user.roleName);
      final matchesRole =
          _selectedRole == 'ALL' || normalizedRole == _selectedRole;
      final matchesQuery =
          query.isEmpty ||
          user.fullName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.phoneNumber.toLowerCase().contains(query) ||
          user.id.toLowerCase().contains(query);
      return matchesRole && matchesQuery;
    }).toList();
  }
}

class _UserCountBadge extends StatelessWidget {
  const _UserCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AdminColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        '$count tài khoản',
        style: AppTextStyles.caption.copyWith(
          color: AdminColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _UserToolbar extends StatelessWidget {
  const _UserToolbar({
    required this.controller,
    required this.selectedRole,
    required this.onSearchChanged,
    required this.onRoleChanged,
    required this.totalUsers,
    required this.activeUsers,
    required this.adminUsers,
  });

  final TextEditingController controller;
  final String selectedRole;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onRoleChanged;
  final int totalUsers;
  final int activeUsers;
  final int adminUsers;

  @override
  Widget build(BuildContext context) {
    return AdminSurface(
      hoverEnabled: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _UserMetric(label: 'Tổng', value: totalUsers),
              const SizedBox(width: AppSpacing.sm),
              _UserMetric(label: 'Hoạt động', value: activeUsers),
              const SizedBox(width: AppSpacing.sm),
              _UserMetric(label: 'Admin', value: adminUsers),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: 'Tìm tên hoặc email...',
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xóa tìm kiếm',
                      onPressed: () {
                        controller.clear();
                        onSearchChanged('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _RoleChip(
                  label: 'Tất cả',
                  value: 'ALL',
                  active: selectedRole == 'ALL',
                  onSelected: onRoleChanged,
                ),
                const SizedBox(width: AppSpacing.sm),
                _RoleChip(
                  label: 'Admin',
                  value: 'ADMIN',
                  active: selectedRole == 'ADMIN',
                  onSelected: onRoleChanged,
                ),
                const SizedBox(width: AppSpacing.sm),
                _RoleChip(
                  label: 'Shipper',
                  value: 'SHIPPER',
                  active: selectedRole == 'SHIPPER',
                  onSelected: onRoleChanged,
                ),
                const SizedBox(width: AppSpacing.sm),
                _RoleChip(
                  label: 'Member',
                  value: 'MEMBER',
                  active: selectedRole == 'MEMBER',
                  onSelected: onRoleChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMetric extends StatelessWidget {
  const _UserMetric({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AdminColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: AppTextStyles.title.copyWith(
                color: AdminColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AdminColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserFormResult {
  const _UserFormResult({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.roleName,
    required this.status,
  });

  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String roleName;
  final bool status;
}

class _UserFormDialog extends StatefulWidget {
  const _UserFormDialog({this.user, required this.roles});

  final AdminUserModel? user;
  final List<AdminRoleModel> roles;

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  static const List<String> _fallbackRoles = ['ADMIN', 'SHIPPER', 'MEMBER'];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController = TextEditingController(
    text: widget.user?.fullName ?? '',
  );
  late final TextEditingController _emailController = TextEditingController(
    text: widget.user?.email ?? '',
  );
  late final TextEditingController _phoneController = TextEditingController(
    text: widget.user?.phoneNumber ?? '',
  );
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  late String _roleName = _normalizeRole(widget.user?.roleName);
  late bool _status = widget.user?.status ?? true;

  bool get _isEditing => widget.user != null;

  List<String> get _roles {
    final values = widget.roles
        .map((role) => RoleMapper.normalize(role.code))
        .where((role) => role.isNotEmpty)
        .toSet()
        .toList();
    return values.isEmpty ? _fallbackRoles : values;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  static String _normalizeRole(String? roleName) {
    final value = RoleMapper.normalize(roleName);
    return _fallbackRoles.contains(value) ? value : 'MEMBER';
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.pop(
      context,
      _UserFormResult(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
        roleName: _roleName,
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        _isEditing ? 'Sửa người dùng' : 'Thêm người dùng',
        style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w800),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AdminFormField(
                controller: _fullNameController,
                label: 'Họ tên',
                required: true,
              ),
              const SizedBox(height: AppSpacing.md),
              AdminFormField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                enabled: !_isEditing,
                required: true,
              ),
              const SizedBox(height: AppSpacing.md),
              AdminFormField(
                controller: _phoneController,
                label: 'Số điện thoại',
                keyboardType: TextInputType.phone,
              ),
              if (!_isEditing) ...[
                const SizedBox(height: AppSpacing.md),
                AdminFormField(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  obscureText: true,
                  required: true,
                ),
                const SizedBox(height: AppSpacing.md),
                AdminFormField(
                  controller: _confirmPasswordController,
                  label: 'Nhập lại mật khẩu',
                  obscureText: true,
                  required: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập lại mật khẩu.';
                    }
                    if (value.trim() != _passwordController.text.trim()) {
                      return 'Mật khẩu nhập lại không khớp.';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Vai trò',
                  style: AppTextStyles.caption.copyWith(
                    color: AdminColors.label,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _roleName,
                decoration: const InputDecoration(),
                items: _roles
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _roleName = value);
                  }
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _status,
                title: const Text('Đang hoạt động'),
                onChanged: _isEditing
                    ? (value) => setState(() => _status = value)
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          onPressed: _submit,
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.value,
    required this.active,
    required this.onSelected,
  });

  final String label;
  final String value;
  final bool active;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: active,
    onSelected: (_) => onSelected(value),
    showCheckmark: false,
    backgroundColor: AdminColors.surface,
    selectedColor: AdminColors.primary,
    labelStyle: TextStyle(
      color: active ? Colors.white : AdminColors.textSecondary,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminUserModel user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final displayName = user.fullName.trim().isEmpty
        ? user.email
        : user.fullName.trim();
    final initial = displayName.isEmpty
        ? '?'
        : displayName.characters.first.toUpperCase();
    final role = RoleMapper.normalize(user.roleName);

    return AdminSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AdminColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Text(
                      initial,
                      style: AppTextStyles.title.copyWith(
                        color: AdminColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: user.status
                            ? AdminColors.success
                            : AdminColors.textSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AdminColors.surface,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle.copyWith(
                        color: AdminColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AdminEntityMenu(onEdit: onEdit, onDelete: onDelete),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _UserPill(
                label: role.isEmpty ? user.roleName : role,
                icon: Icons.admin_panel_settings_outlined,
                color: AdminColors.primary,
                background: AdminColors.primarySoft,
              ),
              const SizedBox(width: AppSpacing.sm),
              _UserPill(
                label: user.status ? 'Hoạt động' : 'Vô hiệu',
                icon: user.status
                    ? Icons.check_circle_outline
                    : Icons.block_outlined,
                color: user.status ? AdminColors.success : AdminColors.danger,
                background: user.status
                    ? AdminColors.successSoft
                    : AdminColors.dangerSoft,
              ),
            ],
          ),
          if (user.phoneNumber.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: AdminColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  user.phoneNumber,
                  style: AppTextStyles.caption.copyWith(
                    color: AdminColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _UserPill extends StatelessWidget {
  const _UserPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
