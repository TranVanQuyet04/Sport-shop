import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminStaffPerformancePage extends StatelessWidget {
  const AdminStaffPerformancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff'), actions: const [IconButton(onPressed: null, icon: Icon(Icons.notifications_none))]),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _Title(),
          SizedBox(height: AppSpacing.lg),
          _Segmented(),
          SizedBox(height: AppSpacing.xl),
          Row(children: [
            Expanded(child: _Metric(icon: Icons.shopping_cart_outlined, title: 'Tổng đơn hàng', value: '1,284', growth: '+12%')),
            SizedBox(width: AppSpacing.lg),
            Expanded(child: _Metric(icon: Icons.verified_outlined, title: 'Tỷ lệ thành công', value: '98.2%', growth: '+0.5%')),
          ]),
          SizedBox(height: AppSpacing.lg),
          _ProcessTime(),
          SizedBox(height: AppSpacing.xl),
          Row(children: [Expanded(child: Text('Xu hướng hiệu suất', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))), Text('CHI TIẾT', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900))]),
          SizedBox(height: AppSpacing.md),
          _ChartPlaceholder(),
          SizedBox(height: AppSpacing.xl),
          Text('Xếp hạng nhân viên', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          SizedBox(height: AppSpacing.md),
          _Rank(name: 'Minh Trần', stat: '248 đơn • 99.5%', rating: 'Tuyệt vời', rank: 1),
          SizedBox(height: AppSpacing.md),
          _Rank(name: 'Linh Nguyễn', stat: '215 đơn • 98.1%', rating: 'Tốt', rank: 2),
          SizedBox(height: AppSpacing.md),
          _Rank(name: 'Hoàng Phan', stat: '198 đơn • 97.4%', rating: 'Ổn định', rank: 3),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Hiệu suất nhân viên', style: AppTextStyles.display.copyWith(fontSize: 34)), Text('Phân tích dữ liệu vận hành thời gian thực', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))]);
}

class _Segmented extends StatelessWidget {
  const _Segmented();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(AppSpacing.xs), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)), child: Row(children: ['Ngày', 'Tuần', 'Tháng'].map((e) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm), decoration: BoxDecoration(color: e == 'Ngày' ? AppColors.surface : Colors.transparent, borderRadius: BorderRadius.circular(AppRadius.sm)), child: Text(e, textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900))))).toList()));
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.title, required this.value, required this.growth});
  final IconData icon; final String title; final String value; final String growth;
  @override
  Widget build(BuildContext context) => DecoratedBox(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)), child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.secondary), const SizedBox(height: AppSpacing.lg), Text(title, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)), Text(value, style: AppTextStyles.display.copyWith(fontSize: 28)), Text('↗ $growth', style: AppTextStyles.body.copyWith(color: AppColors.success, fontWeight: FontWeight.w900))])));
}

class _ProcessTime extends StatelessWidget {
  const _ProcessTime();
  @override
  Widget build(BuildContext context) => DecoratedBox(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)), child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.timer_outlined, color: AppColors.secondary), const SizedBox(height: AppSpacing.md), Text('Thời gian xử lý TB', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)), Text('4m 32s', style: AppTextStyles.display.copyWith(fontSize: 28))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('MỤC TIÊU: < 5M', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: AppSpacing.sm), SizedBox(width: 120, child: LinearProgressIndicator(value: 0.82, color: AppColors.secondary, backgroundColor: AppColors.surfaceMuted))])])));
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder();
  @override
  Widget build(BuildContext context) => Container(height: 170, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)), child: Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].map((e) => Text(e, style: AppTextStyles.caption.copyWith(color: e == 'T4' ? AppColors.secondary : AppColors.primary, fontWeight: FontWeight.w900))).toList()))));
}

class _Rank extends StatelessWidget {
  const _Rank({required this.name, required this.stat, required this.rating, required this.rank});
  final String name; final String stat; final String rating; final int rank;
  @override
  Widget build(BuildContext context) => DecoratedBox(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)), child: ListTile(leading: CircleAvatar(backgroundColor: rank == 1 ? Colors.amber : AppColors.surfaceMuted, child: Text('$rank')), title: Text(name, style: AppTextStyles.subtitle), subtitle: Text(stat), trailing: Text(rating, style: AppTextStyles.body.copyWith(color: rank == 1 ? AppColors.success : AppColors.primary, fontWeight: FontWeight.w900))));
}
