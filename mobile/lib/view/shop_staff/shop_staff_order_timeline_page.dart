import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../admin/widgets/admin_bottom_nav.dart';

class ShopStaffOrderTimelinePage extends StatelessWidget {
  const ShopStaffOrderTimelinePage({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(leading: IconButton(onPressed: context.pop, icon: const Icon(Icons.arrow_back)), title: const Text('TRẠNG THÁI ĐƠN HÀNG'), actions: const [IconButton(onPressed: null, icon: Icon(Icons.notifications_none))]),
        body: ListView(padding: const EdgeInsets.all(AppSpacing.lg), children: [
          DecoratedBox(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)), child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('MÃ ĐƠN HÀNG', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900)), Text('#$orderId', style: AppTextStyles.display.copyWith(fontSize: 28))])), const Chip(label: Text('ĐANG ĐÓNG GÓI'), backgroundColor: AppColors.secondary, labelStyle: TextStyle(color: Colors.white))]),
            const Divider(height: AppSpacing.xl),
            Row(children: [Container(width: 82, height: 82, decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)), child: const Icon(Icons.directions_run, color: AppColors.secondary)), const SizedBox(width: AppSpacing.lg), Expanded(child: Text('Apex Velocity Runner Z1\nSize: 42 | Màu: Đỏ/Đen', style: AppTextStyles.body)), Text('1.250.000đ', style: AppTextStyles.subtitle.copyWith(color: AppColors.secondary))]),
          ]))),
          const SizedBox(height: AppSpacing.xl),
          Text('Lịch trình xử lý', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          const _TimelineStep(title: 'Chờ xác nhận', subtitle: 'Đơn hàng đã được ghi nhận vào hệ thống.', time: '12 THÁNG 5, 2024 - 10:24', done: true),
          const _TimelineStep(title: 'Đã xác nhận', subtitle: 'Thanh toán thành công. Nhân viên đang kiểm tra kho.', time: '12 THÁNG 5, 2024 - 11:15', done: true),
          const _TimelineStep(title: 'Đang đóng gói', subtitle: 'Sản phẩm đang được kiểm tra chất lượng cuối cùng và đóng gói chống sốc.', time: 'HÔM NAY - 08:45', active: true, note: 'Dự kiến bàn giao cho đơn vị vận chuyển trong 2 giờ tới.'),
          const _TimelineStep(title: 'Đã bàn giao', subtitle: 'Đơn vị vận chuyển sẽ cập nhật mã vận đơn khi nhận hàng.', time: '', disabled: true),
          const SizedBox(height: AppSpacing.xl),
          DecoratedBox(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)), child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Text('ĐỊA CHỈ NHẬN HÀNG\n\nNguyễn Văn A\n0908 123 456\n123 Đường Lê Lợi, Phường Bến Thành,\nQuận 1, TP. Hồ Chí Minh', style: AppTextStyles.body))),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [Expanded(child: AppButton(label: 'Liên hệ Shop', variant: AppButtonVariant.outline, onPressed: () {})), const SizedBox(width: AppSpacing.md), Expanded(child: AppButton(label: 'Hủy đơn hàng', onPressed: () {}))]),
        ]),
        bottomNavigationBar: const AdminBottomNav(selectedIndex: 2),
      );
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.title, required this.subtitle, required this.time, this.done = false, this.active = false, this.disabled = false, this.note});
  final String title; final String subtitle; final String time; final bool done; final bool active; final bool disabled; final String? note;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Column(children: [CircleAvatar(radius: active ? 17 : 14, backgroundColor: disabled ? AppColors.surfaceMuted : active ? AppColors.secondary : AppColors.primary, child: Icon(done ? Icons.check : active ? Icons.circle : Icons.circle, color: Colors.white, size: active ? 13 : 16)), Container(width: 2, height: note == null ? 78 : 124, color: AppColors.surfaceMuted)]),
    const SizedBox(width: AppSpacing.lg),
    Expanded(child: Padding(padding: const EdgeInsets.only(bottom: AppSpacing.lg), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.subtitle.copyWith(color: active ? AppColors.secondary : disabled ? AppColors.textSecondary : AppColors.primary)), Text(subtitle, style: AppTextStyles.body.copyWith(color: disabled ? AppColors.textSecondary : AppColors.primary, fontWeight: active ? FontWeight.w700 : FontWeight.w400)), if (time.isNotEmpty) Text(time, style: AppTextStyles.caption.copyWith(color: active ? AppColors.secondary : AppColors.textSecondary, fontWeight: FontWeight.w900)), if (note != null) ...[const SizedBox(height: AppSpacing.md), DecoratedBox(decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(AppRadius.md)), child: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: Text(note!, style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic))))]]))),
  ]);
}
