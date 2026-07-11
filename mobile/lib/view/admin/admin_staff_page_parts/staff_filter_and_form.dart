part of '../admin_staff_page.dart';

enum _StaffFilter {
  all('Tất cả'),
  active('Hoạt động'),
  admin('Admin'),
  shipper('Shipper');

  const _StaffFilter(this.label);
  final String label;
}

class _StaffFormResult {
  const _StaffFormResult({
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

class _StaffFormDialog extends StatefulWidget {
  const _StaffFormDialog({this.user});

  final AdminUserModel? user;

  @override
  State<_StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<_StaffFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late String _roleName;
  late bool _status;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _roleName = _normalizeStaffRole(user?.roleName ?? 'ADMIN');
    _status = user?.status ?? true;
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

  String _normalizeStaffRole(String roleName) {
    final value = roleName.trim().toUpperCase();
    return value == 'SHIPPER' ? 'SHIPPER' : 'ADMIN';
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Vui lòng nhập email.';
    if (!email.contains('@')) return 'Email không hợp lệ.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (_isEditing) return null;
    final password = value?.trim() ?? '';
    if (password.length < 6) return 'Mật khẩu tối thiểu 6 ký tự.';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (_isEditing) return null;
    final confirmPassword = value?.trim() ?? '';
    if (confirmPassword.isEmpty) return 'Vui lòng nhập lại mật khẩu.';
    if (confirmPassword != _passwordController.text.trim()) {
      return 'Mật khẩu nhập lại không khớp.';
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.pop(
      context,
      _StaffFormResult(
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
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        _isEditing ? 'Chỉnh sửa nhân viên' : 'Thêm nhân viên',
        style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w800),
      ),
      content: SizedBox(
        width: 420,
        child: Form(
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
                  validator: _validateEmail,
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
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AdminFormField(
                    controller: _confirmPasswordController,
                    label: 'Nhập lại mật khẩu',
                    obscureText: true,
                    required: true,
                    validator: _validateConfirmPassword,
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
                  items: const [
                    DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                    DropdownMenuItem(value: 'SHIPPER', child: Text('SHIPPER')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _roleName = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Material(
                  color: AdminColors.surfaceMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    side: const BorderSide(color: AdminColors.border),
                  ),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    value: _status,
                    title: Text(
                      'Đang hoạt động',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      'Tắt trạng thái nếu nhân viên tạm ngưng làm việc.',
                      style: AppTextStyles.caption.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                    activeThumbColor: AdminColors.primary,
                    onChanged: (value) => setState(() => _status = value),
                  ),
                ),
              ],
            ),
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
