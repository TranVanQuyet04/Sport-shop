import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

class AdminStaffPage extends StatefulWidget {
  const AdminStaffPage({super.key});

  @override
  State<AdminStaffPage> createState() => _AdminStaffPageState();
}

class _AdminStaffPageState extends State<AdminStaffPage> {
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );
  final TextEditingController _searchController = TextEditingController();
  _StaffFilter _selectedFilter = _StaffFilter.all;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadUsers();
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

  List<AdminUserModel> get _staffUsers {
    return _controller.users.where((user) {
      final role = user.roleName.toUpperCase();
      return role == 'ADMIN' || role == 'SHIPPER';
    }).toList();
  }

  List<AdminUserModel> get _visibleStaff {
    final query = _searchController.text.trim().toLowerCase();
    return _staffUsers.where((user) {
      final matchesFilter = switch (_selectedFilter) {
        _StaffFilter.all => true,
        _StaffFilter.admin => user.roleName.toUpperCase() == 'ADMIN',
        _StaffFilter.shipper => user.roleName.toUpperCase() == 'SHIPPER',
        _StaffFilter.active => user.status,
      };
      final matchesQuery =
          query.isEmpty ||
          user.fullName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.phoneNumber.toLowerCase().contains(query) ||
          user.id.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  void _showPhone(AdminUserModel user) {
    final phone = user.phoneNumber.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          phone.isEmpty
              ? '${user.fullName} chưa cập nhật số điện thoại.'
              : 'Số điện thoại: $phone',
        ),
      ),
    );
  }

  Future<void> _openStaffCreateForm() async {
    final result = await showDialog<_StaffFormResult>(
      context: context,
      builder: (context) => const _StaffFormDialog(),
    );
    if (result == null || !mounted) return;

    final success = await _controller.saveUser(
      fullName: result.fullName,
      email: result.email,
      phoneNumber: result.phoneNumber,
      password: result.password,
      confirmPassword: result.confirmPassword,
      roleName: result.roleName,
      status: result.status,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã thêm nhân viên ${result.fullName}.'
              : (_controller.errorMessage ?? 'Không thể thêm nhân viên.'),
        ),
      ),
    );
  }

  Future<void> _openStaffEditForm(AdminUserModel user) async {
    final result = await showDialog<_StaffFormResult>(
      context: context,
      builder: (context) => _StaffFormDialog(user: user),
    );
    if (result == null || !mounted) return;

    final success = await _controller.saveUser(
      id: user.id,
      fullName: result.fullName,
      email: result.email,
      phoneNumber: result.phoneNumber,
      password: result.password,
      confirmPassword: result.confirmPassword,
      roleName: result.roleName,
      status: result.status,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã cập nhật nhân viên ${result.fullName}.'
              : (_controller.errorMessage ?? 'Không thể cập nhật nhân viên.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _controller.loadUsers,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller.isSubmitting ? null : _openStaffCreateForm,
        tooltip: 'Thêm nhân viên',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.person_add_alt_1),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildBody() {
    final staffUsers = _staffUsers;
    if (_controller.isLoading && staffUsers.isEmpty) {
      return const AppLoadingState(title: 'Đang tải nhân viên');
    }
    if (_controller.errorMessage != null && staffUsers.isEmpty) {
      return AppErrorState(
        title: 'Không tải được nhân viên',
        message: _controller.errorMessage!,
        onAction: _controller.loadUsers,
      );
    }

    final visibleStaff = _visibleStaff;
    final activeCount = staffUsers.where((user) => user.status).length;
    final shipperCount = staffUsers
        .where((user) => user.roleName.toUpperCase() == 'SHIPPER')
        .length;

    return AbsolutePersistentLayout(
      title: 'Quản lý nhân viên',
      subtitle: 'Theo dõi tài khoản quản trị và đội ngũ giao hàng.',
      icon: Icons.groups_2_outlined,
      trailing: _StaffSummaryPill(
        total: staffUsers.length,
        active: activeCount,
        shippers: shipperCount,
      ),
      filterAndSearchZone: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_controller.errorMessage != null) ...[
            AdminInlineBanner(
              message: _controller.errorMessage!,
              onRefresh: _controller.loadUsers,
              isError: true,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          _StaffToolbar(
            controller: _searchController,
            selectedFilter: _selectedFilter,
            onSearchChanged: (_) => setState(() {}),
            onFilterChanged: (filter) {
              setState(() => _selectedFilter = filter);
            },
          ),
        ],
      ),
      dynamicContent: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 0),
        children: [
          AdminSectionTitle(
            title: 'Danh sách nhân viên',
            subtitle: '${visibleStaff.length} kết quả phù hợp',
            trailing: IconButton(
              tooltip: 'Làm mới',
              onPressed: _controller.isLoading ? null : _controller.loadUsers,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (visibleStaff.isEmpty)
            PremiumEmptyState(
              icon: Icons.groups_2_outlined,
              title: 'Không tìm thấy nhân viên',
              message: 'Thử thay đổi từ khóa hoặc bộ lọc hiện tại.',
              actionLabel: 'Xóa bộ lọc',
              onAction: () {
                _searchController.clear();
                setState(() => _selectedFilter = _StaffFilter.all);
              },
            )
          else
            ...visibleStaff.indexed.map(
              (entry) => _StaggeredEmployeeCard(
                key: ValueKey(entry.$2.id),
                index: entry.$1,
                child: EmployeeCard(
                  user: entry.$2,
                  onTap: () => context.go('/admin/staff/${entry.$2.id}'),
                  onPhone: () => _showPhone(entry.$2),
                  onEdit: () => _openStaffEditForm(entry.$2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
                Container(
                  decoration: BoxDecoration(
                    color: AdminColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AdminColors.border),
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

class _StaffSummaryPill extends StatelessWidget {
  const _StaffSummaryPill({
    required this.total,
    required this.active,
    required this.shippers,
  });

  final int total;
  final int active;
  final int shippers;

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
        '$total tổng · $active hoạt động · $shippers shipper',
        style: AppTextStyles.caption.copyWith(
          color: AdminColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StaffToolbar extends StatelessWidget {
  const _StaffToolbar({
    required this.controller,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final _StaffFilter selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_StaffFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final hasFilter = selectedFilter != _StaffFilter.all;
    return AdminSurface(
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Tìm theo tên, email, số điện thoại hoặc mã...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xóa tìm kiếm',
                      onPressed: () {
                        controller.clear();
                        onSearchChanged('');
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterIndicator(active: hasFilter),
                const SizedBox(width: AppSpacing.sm),
                for (final filter in _StaffFilter.values) ...[
                  ChoiceChip(
                    label: Text(filter.label),
                    selected: selectedFilter == filter,
                    showCheckmark: false,
                    onSelected: (_) => onFilterChanged(filter),
                    selectedColor: AdminColors.primary,
                    backgroundColor: AdminColors.surfaceMuted,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    labelStyle: AppTextStyles.caption.copyWith(
                      color: selectedFilter == filter
                          ? Colors.white
                          : AdminColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterIndicator extends StatelessWidget {
  const _FilterIndicator({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AdminColors.navy,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            children: [
              Icon(Icons.tune_rounded, color: Colors.white, size: 18),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Bộ lọc',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (active)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: AdminColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _StaggeredEmployeeCard extends StatefulWidget {
  const _StaggeredEmployeeCard({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<_StaggeredEmployeeCard> createState() => _StaggeredEmployeeCardState();
}

class _StaggeredEmployeeCardState extends State<_StaggeredEmployeeCard> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 55 * widget.index.clamp(0, 8));
    _timer = Timer(delay, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.12),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: widget.child,
        ),
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({
    super.key,
    required this.user,
    required this.onTap,
    required this.onPhone,
    required this.onEdit,
  });

  final AdminUserModel user;
  final VoidCallback onTap;
  final VoidCallback onPhone;
  final VoidCallback onEdit;

  bool get _isShipper => user.roleName.toUpperCase() == 'SHIPPER';

  String get _initials {
    final parts = user.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _isShipper ? AdminColors.primary : AdminColors.accent;
    final softAccent = _isShipper
        ? AdminColors.primarySoft
        : AdminColors.accentSoft;
    final secondaryText = user.email.isNotEmpty
        ? user.email
        : (user.phoneNumber.isNotEmpty
              ? user.phoneNumber
              : 'Chưa cập nhật thông tin liên hệ');

    return AdminSurface(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 440;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EmployeeAvatar(
                    initials: _initials,
                    active: user.status,
                    accent: accent,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.fullName.isEmpty
                                    ? 'Chưa cập nhật tên'
                                    : user.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.title.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (!compact)
                              _RoleBadge(
                                label: user.roleName,
                                color: accent,
                                background: softAccent,
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          secondaryText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: AdminColors.textSecondary,
                          ),
                        ),
                        if (compact) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _RoleBadge(
                            label: user.roleName,
                            color: accent,
                            background: softAccent,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 1, color: AdminColors.border),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _MetadataItem(
                      icon: Icons.badge_outlined,
                      label: 'Mã nhân viên',
                      value: user.id.isEmpty
                          ? 'Chưa có dữ liệu'
                          : '#${user.id}',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _MetadataItem(
                      icon: _isShipper
                          ? Icons.local_shipping_outlined
                          : Icons.calendar_today_outlined,
                      label: _isShipper ? 'Đơn đang giao' : 'Ngày tham gia',
                      value: 'Chưa có dữ liệu',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _QuickIconButton(
                    tooltip: 'Số điện thoại',
                    icon: Icons.phone_outlined,
                    onPressed: onPhone,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _QuickIconButton(
                    tooltip: 'Chỉnh sửa',
                    icon: Icons.edit_outlined,
                    onPressed: onEdit,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmployeeAvatar extends StatelessWidget {
  const _EmployeeAvatar({
    required this.initials,
    required this.active,
    required this.accent,
  });

  final String initials;
  final bool active;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent, Color.lerp(accent, AdminColors.navy, 0.35)!],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.24),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            initials,
            style: AppTextStyles.subtitle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Positioned(
          right: -3,
          bottom: -3,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: active ? AdminColors.success : AdminColors.textSecondary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetadataItem extends StatelessWidget {
  const _MetadataItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AdminColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AdminColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AdminColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickIconButton extends StatelessWidget {
  const _QuickIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: AdminColors.primary,
        backgroundColor: AdminColors.primarySoft,
        minimumSize: const Size(38, 38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      icon: Icon(icon, size: 18),
    );
  }
}
