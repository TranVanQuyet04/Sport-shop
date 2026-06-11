import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/order_status_badge.dart';
import '../../model/common/delivery_status.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminDeliveryMonitoringPage extends StatelessWidget {
  const AdminDeliveryMonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _Header(),
          SizedBox(height: AppSpacing.lg),
          TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Tìm mã đơn hàng hoặc nhân viên...')),
          SizedBox(height: AppSpacing.md),
          Wrap(spacing: AppSpacing.md, runSpacing: AppSpacing.md, children: [
            _DeliveryChip(label: 'Tất cả', active: true),
            _DeliveryChip(label: 'Đang giao'),
            _DeliveryChip(label: 'Lấy hàng'),
            _DeliveryChip(label: 'Lỗi/Trả lại', warning: true),
          ]),
          SizedBox(height: AppSpacing.xl),
          _DeliveryCard(status: DeliveryStatus.failed, code: '#AV-88320', detail: '45 Lê Lợi, Quận 1, TP. HCM\nNhân viên: Trần Văn A', alert: true, note: 'Lý do: Khách hàng không nghe máy sau 3 lần gọi.'),
          _DeliveryCard(status: DeliveryStatus.outForDelivery, code: '#AV-91244', detail: 'Điểm đến: KĐT Sala, Quận 2\nDự kiến: 14:30 Hôm nay', progress: 0.75),
          _DeliveryCard(status: DeliveryStatus.inTransit, code: '#AV-92001', detail: 'Vinhomes Central Park, Bình Thạnh\nNhân viên: Lê Thị B', action: 'XEM BẢN ĐỒ'),
          _DeliveryCard(status: DeliveryStatus.returned, code: '#AV-87112', detail: 'Yêu cầu hoàn trả bởi người mua\nCập nhật: 2 giờ trước'),
        ],
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, onPressed: () {}, child: const Icon(Icons.add)),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 2),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Theo dõi giao hàng', style: AppTextStyles.display.copyWith(fontSize: 34)), Text('Giám sát trạng thái vận chuyển thời gian thực của các đơn hàng đang hoạt động.', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 18))]);
}

class _DeliveryChip extends StatelessWidget {
  const _DeliveryChip({required this.label, this.active = false, this.warning = false});
  final String label;
  final bool active;
  final bool warning;
  @override
  Widget build(BuildContext context) => Chip(label: Text(label), backgroundColor: active ? AppColors.primary : warning ? const Color(0xFFFFD9D9) : AppColors.surfaceMuted, labelStyle: TextStyle(color: active ? Colors.white : warning ? AppColors.secondary : AppColors.primary, fontWeight: FontWeight.w900));
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.status, required this.code, required this.detail, this.alert = false, this.note, this.progress, this.action});
  final DeliveryStatus status;
  final String code;
  final String detail;
  final bool alert;
  final String? note;
  final double? progress;
  final String? action;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), border: alert ? const Border(left: BorderSide(color: AppColors.secondary, width: 4)) : null),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            DeliveryStatusBadge(status: status),
            const SizedBox(height: AppSpacing.sm),
            Text(code, style: AppTextStyles.display.copyWith(fontSize: 26)),
            const SizedBox(height: AppSpacing.md),
            Text(detail, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            if (note != null) ...[const SizedBox(height: AppSpacing.md), DecoratedBox(decoration: BoxDecoration(color: const Color(0xFFFFF2F2), borderRadius: BorderRadius.circular(AppRadius.md)), child: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: Text(note!, style: AppTextStyles.caption.copyWith(color: AppColors.secondary))))],
            if (progress != null) ...[const SizedBox(height: AppSpacing.lg), LinearProgressIndicator(value: progress, color: AppColors.secondary, backgroundColor: AppColors.surfaceMuted), const SizedBox(height: AppSpacing.xs), Align(alignment: Alignment.centerRight, child: Text('${(progress! * 100).round()}%', style: AppTextStyles.caption.copyWith(color: AppColors.secondary)))],
            if (action != null) ...[const SizedBox(height: AppSpacing.lg), FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(52)), onPressed: () {}, child: Text(action!))],
          ]),
        ),
      );
}
