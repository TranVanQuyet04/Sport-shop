import 'package:flutter/material.dart';

import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import 'widgets/admin_bottom_nav.dart';

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

  Future<void> _openUserForm([AdminUserModel? user]) async {
    final result = await showDialog<_UserFormResult>(
      context: context,
      builder: (_) => _UserFormDialog(user: user),
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
          onPressed: _controller.isLoading ? null : _controller.loadUsers,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _controller.loadUsers,
      child: _buildBody(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
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
      return const AppEmptyState(title: 'Chưa có người dùng');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _controller.users.length + 3,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Text(
            'Quản lý người dùng',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
          );
        }
        if (index == 1) {
          return const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm tên, email...',
            ),
          );
        }
        if (index == 2) {
          return const Wrap(
            spacing: AppSpacing.md,
            children: [
              _RoleChip(label: 'Tất cả', active: true),
              _RoleChip(label: 'Admin'),
              _RoleChip(label: 'Shop staff'),
              _RoleChip(label: 'Delivery'),
            ],
          );
        }
        final user = _controller.users[index - 3];
        return _UserCard(
          user: user,
          onEdit: () => _openUserForm(user),
          onDelete: () => _deleteUser(user),
        );
      },
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
  const _UserFormDialog({this.user});

  final AdminUserModel? user;

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  static const List<String> _roles = [
    'ADMIN',
    'SHOP_STAFF',
    'DELIVERY_STAFF',
    'CUSTOMER',
  ];

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
    final value = (roleName ?? '').trim().toUpperCase();
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
      title: Text(_isEditing ? 'Sửa người dùng' : 'Thêm người dùng'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(
                controller: _fullNameController,
                label: 'Họ tên',
                required: true,
              ),
              _DialogField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                enabled: !_isEditing,
                required: true,
              ),
              _DialogField(
                controller: _phoneController,
                label: 'Số điện thoại',
                keyboardType: TextInputType.phone,
              ),
              if (!_isEditing) ...[
                _DialogField(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  obscureText: true,
                  required: true,
                ),
                _DialogField(
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
              DropdownButtonFormField<String>(
                initialValue: _roleName,
                decoration: const InputDecoration(labelText: 'Vai trò'),
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
        FilledButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.enabled = true,
    this.required = false,
    this.obscureText = false,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool required;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        obscureText: obscureText,
        decoration: InputDecoration(labelText: label),
        validator:
            validator ??
            (value) {
              if (required && (value == null || value.trim().isEmpty)) {
                return 'Vui lòng nhập $label.';
              }
              return null;
            },
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(label),
    backgroundColor: active ? AppColors.primary : AppColors.surfaceMuted,
    labelStyle: TextStyle(
      color: active ? Colors.white : AppColors.primary,
      fontWeight: FontWeight.w900,
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
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 36, child: Icon(Icons.person)),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: AppTextStyles.title),
                    Text(user.email),
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
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  'VAI TRÒ\n${user.roleName}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'TRẠNG THÁI\n${user.status ? 'Hoạt động' : 'Vô hiệu'}',
                textAlign: TextAlign.right,
                style: AppTextStyles.body.copyWith(
                  color: user.status ? AppColors.success : AppColors.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
