import 'package:flutter/material.dart';

import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminCategoryManagementPage extends StatefulWidget {
  const AdminCategoryManagementPage({super.key});

  @override
  State<AdminCategoryManagementPage> createState() =>
      _AdminCategoryManagementPageState();
}

class _AdminCategoryManagementPageState
    extends State<AdminCategoryManagementPage> {
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadCategories();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý danh mục'),
        actions: [
          IconButton(
            onPressed: _controller.loadCategories,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _controller.loadCategories,
        child: _buildBody(),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppButton(
                label: 'Thêm danh mục mới',
                variant: AppButtonVariant.secondary,
                icon: Icons.add_circle_outline,
                onPressed: null,
              ),
            ),
            const AdminBottomNav(selectedIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.categories.isEmpty) {
      return const AppLoadingState(title: 'Đang tải danh mục');
    }
    if (_controller.errorMessage != null && _controller.categories.isEmpty) {
      return AppErrorState(
        title: 'Không tải được danh mục',
        message: _controller.errorMessage!,
        onAction: _controller.loadCategories,
      );
    }
    if (_controller.categories.isEmpty) {
      return const AppEmptyState(title: 'Chưa có danh mục');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _controller.categories.length + 2,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm kiếm danh mục...',
            ),
          );
        }
        if (index == 1) {
          return const _Title(
            title: 'Quản lý danh mục',
            subtitle: 'Dữ liệu lấy từ API admin/categories',
          );
        }
        return _CategoryTile(category: _controller.categories[index - 2]);
      },
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppTextStyles.display.copyWith(fontSize: 34)),
      Text(
        subtitle,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
          fontSize: 18,
        ),
      ),
    ],
  );
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final AdminCategoryModel category;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: AppColors.border),
    ),
    child: ListTile(
      minVerticalPadding: AppSpacing.lg,
      leading: const CircleAvatar(child: Icon(Icons.category_outlined)),
      title: Text(category.name, style: AppTextStyles.title),
      subtitle: Text(
        category.description.isEmpty ? 'Không có mô tả' : category.description,
      ),
      trailing: Text('#${category.id}'),
    ),
  );
}
