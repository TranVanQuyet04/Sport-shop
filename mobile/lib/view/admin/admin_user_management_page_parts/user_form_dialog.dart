part of '../admin_user_management_page.dart';

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
