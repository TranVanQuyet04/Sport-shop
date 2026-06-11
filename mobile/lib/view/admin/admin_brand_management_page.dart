import 'package:flutter/material.dart';

import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminBrandManagementPage extends StatefulWidget {
  const AdminBrandManagementPage({super.key});

  @override
  State<AdminBrandManagementPage> createState() =>
      _AdminBrandManagementPageState();
}

class _AdminBrandManagementPageState extends State<AdminBrandManagementPage> {
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadBrands();
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
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _controller.loadBrands,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.brands.isEmpty) {
      return const AppLoadingState(title: 'Đang tải thương hiệu');
    }
    if (_controller.errorMessage != null && _controller.brands.isEmpty) {
      return AppErrorState(
        title: 'Không tải được thương hiệu',
        message: _controller.errorMessage!,
        onAction: _controller.loadBrands,
      );
    }
    if (_controller.brands.isEmpty) {
      return const AppEmptyState(title: 'Chưa có thương hiệu');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _controller.brands.length + 2,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _Header();
        }
        if (index == 1) {
          return const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm kiếm thương hiệu...',
            ),
          );
        }
        return _BrandTile(brand: _controller.brands[index - 2]);
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Quản lý thương hiệu',
        style: AppTextStyles.display.copyWith(fontSize: 36),
      ),
      Text(
        'Dữ liệu lấy từ API brands.',
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
          fontSize: 18,
        ),
      ),
    ],
  );
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({required this.brand});

  final AdminBrandModel brand;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
    ),
    child: ListTile(
      minVerticalPadding: AppSpacing.lg,
      leading: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Center(
          child: Text(
            brand.name.isEmpty ? '?' : brand.name.characters.first,
            style: AppTextStyles.title,
          ),
        ),
      ),
      title: Text(
        brand.name,
        style: AppTextStyles.display.copyWith(fontSize: 28),
      ),
      subtitle: Text(
        brand.description.isEmpty
            ? (brand.isActive ? 'Đang hoạt động' : 'Đã tắt')
            : brand.description,
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.edit),
    ),
  );
}
