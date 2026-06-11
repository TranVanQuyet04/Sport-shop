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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Quản lý người dùng'),
      actions: [
        IconButton(
          onPressed: _controller.loadUsers,
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
      onPressed: null,
      child: const Icon(Icons.person_add_alt),
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
              _RoleChip(label: 'Staff'),
              _RoleChip(label: 'Customer'),
            ],
          );
        }
        return _UserCard(user: _controller.users[index - 3]);
      },
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
  const _UserCard({required this.user});

  final AdminUserModel user;

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
              const Icon(Icons.more_vert),
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
