import 'package:flutter/material.dart';

import '../../presenter/admin/admin_catalog_presenter.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/auth/role_mapper.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

part 'admin_user_management_page_parts/user_toolbar_widgets.dart';
part 'admin_user_management_page_parts/user_form_dialog.dart';
part 'admin_user_management_page_parts/user_card_widgets.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key, this.initialRole});

  final String? initialRole;

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  late final AdminCatalogPresenter _presenter = AdminCatalogPresenter(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'ALL';

  @override
  void initState() {
    super.initState();
    final initialRole = RoleMapper.normalize(widget.initialRole);
    if (initialRole.isNotEmpty) {
      _selectedRole = initialRole;
    }
    _presenter.addListener(_onControllerChanged);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_presenter.loadUsers(), _presenter.loadRoles()]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _presenter
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
      builder: (_) => _UserFormDialog(user: user, roles: _presenter.roles),
    );
    if (result == null) {
      return;
    }

    final success = await _presenter.saveUser(
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

    final success = await _presenter.deleteUser(user.id);
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
              : (_presenter.errorMessage ?? 'Thao tác chưa thành công.'),
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
          tooltip: 'Làm mới người dùng',
          onPressed: _presenter.isLoading ? null : _loadData,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: RefreshIndicator(onRefresh: _loadData, child: _buildBody()),
    floatingActionButton: FloatingActionButton(
      tooltip: 'Thêm người dùng',
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      onPressed: _presenter.isSubmitting ? null : () => _openUserForm(),
      child: _presenter.isSubmitting
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
    if (_presenter.isLoading && _presenter.users.isEmpty) {
      return const AppLoadingState(title: 'Đang tải người dùng');
    }
    if (_presenter.errorMessage != null && _presenter.users.isEmpty) {
      return AppErrorState(
        title: 'Không tải được người dùng',
        message: _presenter.errorMessage!,
        onAction: _presenter.loadUsers,
      );
    }
    if (_presenter.users.isEmpty) {
      return PremiumEmptyState(
        icon: Icons.manage_accounts_outlined,
        title: 'Chưa có người dùng',
        message: 'Tạo tài khoản để phân quyền Admin, Shipper hoặc khách hàng.',
        actionLabel: 'Thêm mới ngay',
        onAction: () => _openUserForm(),
      );
    }
    final visibleUsers = _visibleUsers;
    final activeUsers = _presenter.users.where((user) => user.status).length;
    final adminUsers = _presenter.users
        .where((user) => RoleMapper.normalize(user.roleName) == 'ADMIN')
        .length;
    return AbsolutePersistentLayout(
      title: 'Quản lý người dùng',
      subtitle: 'Kiểm soát tài khoản, vai trò và trạng thái truy cập hệ thống.',
      icon: Icons.manage_accounts_outlined,
      trailing: _UserCountBadge(count: _presenter.users.length),
      filterAndSearchZone: _UserToolbar(
        controller: _searchController,
        selectedRole: _selectedRole,
        onSearchChanged: (_) => setState(() {}),
        onRoleChanged: (role) => setState(() => _selectedRole = role),
        totalUsers: _presenter.users.length,
        activeUsers: activeUsers,
        adminUsers: adminUsers,
      ),
      dynamicContent: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          104,
        ),
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
    return _presenter.users.where((user) {
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
