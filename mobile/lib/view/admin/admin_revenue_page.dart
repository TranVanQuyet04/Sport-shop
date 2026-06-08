import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminRevenuePage extends StatelessWidget {
  const AdminRevenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(largeLogo: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Tổng quan Doanh thu', style: AppTextStyles.display.copyWith(fontSize: 30)),
          const SizedBox(height: AppSpacing.xs),
          Text('Cập nhật lúc 09:41, Hôm nay', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Row(
              children: ['Ngày', 'Tuần', 'Tháng', 'Quý', 'Năm'].map((label) {
                final active = label == 'Ngày';
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(color: active ? AppColors.surface : Colors.transparent, borderRadius: BorderRadius.circular(AppRadius.sm)),
                    child: Text(label, textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          DecoratedBox(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _RevenueMetric(label: 'TỔNG DOANH THU', value: '1.284.000.000đ', growth: '+12.5%')),
                      _RevenueMetric(label: 'ĐƠN HÀNG', value: '3.412', growth: '+8.2%'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    height: 220,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [72, 110, 145, 190, 225, 170, 205].map((height) {
                        final active = height == 225;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Container(
                              height: height.toDouble(),
                              decoration: BoxDecoration(color: active ? AppColors.primary : AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.sm)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['08:00', '12:00', '16:00', '20:00', '00:00'].map((e) => Text(e, style: AppTextStyles.caption)).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Phân tích theo danh mục', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              Expanded(child: _CategoryRevenue(icon: Icons.directions_run, title: 'GIÀY CHẠY BỘ', value: '542.0tr', progress: 0.45)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _CategoryRevenue(icon: Icons.checkroom, title: 'QUẦN ÁO', value: '315.5tr', progress: 0.32)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _CategoryRevenue(icon: Icons.trending_up, title: 'PHỤ KIỆN', value: '426.5tr', progress: 0.54),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(child: Text('Sản phẩm bán chạy', style: AppTextStyles.title)),
              TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
            ],
          ),
          const _BestSeller(name: 'Apex Carbon Pro', orders: '342 đơn hàng', value: '4.2M', growth: '+4.5%'),
          const _BestSeller(name: 'Velocity Compression', orders: '288 đơn hàng', value: '1.1M', growth: '+12.1%'),
          const _BestSeller(name: 'Pace Split Shorts', orders: '195 đơn hàng', value: '0.8M', growth: '-2.3%'),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 0),
    );
  }
}

class _RevenueMetric extends StatelessWidget {
  const _RevenueMetric({required this.label, required this.value, required this.growth});

  final String label;
  final String value;
  final String growth;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900)),
      const SizedBox(height: AppSpacing.sm),
      Text(value, style: AppTextStyles.display.copyWith(fontSize: 26)),
      Text('↗ $growth', style: AppTextStyles.caption.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w900)),
    ]);
  }
}

class _CategoryRevenue extends StatelessWidget {
  const _CategoryRevenue({required this.icon, required this.title, required this.value, required this.progress});

  final IconData icon;
  final String title;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: AppColors.secondary),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(value: progress, color: AppColors.primary, backgroundColor: AppColors.surfaceMuted),
        ]),
      ),
    );
  }
}

class _BestSeller extends StatelessWidget {
  const _BestSeller({required this.name, required this.orders, required this.value, required this.growth});

  final String name;
  final String orders;
  final String value;
  final String growth;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      leading: Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)), child: const Icon(Icons.directions_run, color: AppColors.secondary)),
      title: Text(name, style: AppTextStyles.subtitle),
      subtitle: Text(orders),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(value, style: AppTextStyles.title),
        Text(growth, style: AppTextStyles.caption.copyWith(color: growth.startsWith('-') ? AppColors.primary : AppColors.secondary)),
      ]),
    );
  }
}
