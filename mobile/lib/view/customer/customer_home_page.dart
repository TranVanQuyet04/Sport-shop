import 'package:flutter/material.dart';

import '../../controller/customer/customer_home_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/customer_bottom_nav.dart';
import 'widgets/product_card.dart';
import 'widgets/sportshop_logo.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  late final CustomerHomeController _controller = CustomerHomeController(
    productRepository: AppDependencies.instance.productRepository,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadHome();
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
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        title: const SportshopLogo(compact: true),
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.notifications_none)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
        children: [
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm trang phục thể thao...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            constraints: const BoxConstraints(minHeight: 186),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A2A2E), Color(0xFFDCD9FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    child: Text(
                      'LIMITED TIME',
                      style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'SALE OFF 50%',
                  style: AppTextStyles.display.copyWith(color: Colors.white, fontSize: 32),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Nâng tầm hiệu suất của bạn ngay hôm nay.',
                  style: AppTextStyles.body.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  onPressed: () {},
                  child: const Text('Mua Ngay'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(child: Text('Danh mục', style: AppTextStyles.title)),
              Text('TẤT CẢ', style: AppTextStyles.caption.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: const [
              _CategoryItem(icon: Icons.directions_run, label: 'Giày'),
              _CategoryItem(icon: Icons.checkroom, label: 'Áo'),
              _CategoryItem(icon: Icons.backpack_outlined, label: 'Túi'),
              _CategoryItem(icon: Icons.sports_basketball, label: 'Phụ kiện'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Thương hiệu nổi bật', style: AppTextStyles.title),
                const SizedBox.shrink(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BrandLabel(label: 'NIKE'),
              _BrandLabel(label: 'adidas'),
              _BrandLabel(label: 'PUMA'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(child: Text('Sản phẩm gợi ý', style: AppTextStyles.title)),
              const Icon(Icons.tune),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.xl,
              childAspectRatio: 0.72,
            ),
            itemCount: _controller.recommendedProducts.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: _controller.recommendedProducts[index],
                index: index,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedIndex: 0),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.primary,
            child: Icon(icon),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _BrandLabel extends StatelessWidget {
  const _BrandLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF6F6F73),
        fontSize: 24,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
