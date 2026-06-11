import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/order_status_badge.dart';
import '../../model/common/delivery_status.dart';
import 'widgets/customer_bottom_nav.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: context.pop, icon: const Icon(Icons.arrow_back)),
        title: Text('THEO DÕI ĐƠN HÀNG', style: AppTextStyles.display.copyWith(fontSize: 24)),
        actions: const [IconButton(onPressed: null, icon: Icon(Icons.help_outline))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('MÃ ĐƠN HÀNG', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900))),
                      const DeliveryStatusBadge(status: DeliveryStatus.outForDelivery),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('#$orderId', style: AppTextStyles.display.copyWith(fontSize: 28)),
                  const Divider(height: AppSpacing.xl),
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)),
                        child: const Icon(Icons.directions_run, color: AppColors.secondary, size: 36),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: Text('Apex Velocity\nElite Z1\nSize: 42 | Màu: Speed Red', style: AppTextStyles.body)),
                      Text('3.250.000đ', style: AppTextStyles.title),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            height: 190,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFFC7C7C7),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('VỊ TRÍ HIỆN TẠI', style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                Row(
                  children: [
                    Expanded(child: Text('Trạm trung chuyển Quận 7, TP.HCM', style: AppTextStyles.subtitle.copyWith(color: Colors.white))),
                    const CircleAvatar(backgroundColor: AppColors.primary, foregroundColor: Colors.white, child: Icon(Icons.navigation)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          DecoratedBox(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.route, color: AppColors.secondary),
                      const SizedBox(width: AppSpacing.md),
                      Text('Hành trình đơn hàng', style: AppTextStyles.title),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _TimelineItem(active: true, title: 'Đang giao hàng', time: '14:30 - Hôm nay', subtitle: 'Shipper đang trên đường giao đến bạn. Vui lòng giữ máy.'),
                  const _TimelineItem(title: 'Đang vận chuyển', time: '08:15 - Hôm nay', subtitle: 'Đơn hàng đã rời kho phân loại và đang được chuyển đến bưu cục địa phương.'),
                  const _TimelineItem(title: 'Đã lấy hàng', time: '21:00 - 20 Th10', subtitle: 'Đơn vị vận chuyển đã lấy hàng thành công từ kho Apex.'),
                  const _TimelineItem(title: 'Đóng gói hoàn tất', time: '18:45 - 20 Th10', subtitle: 'Sản phẩm của bạn đã được kiểm tra chất lượng và đóng gói cẩn thận.'),
                  const _TimelineItem(last: true, title: 'Xác nhận đơn hàng', time: '15:20 - 20 Th10', subtitle: 'Apex đã xác nhận thanh toán và đang chuẩn bị đơn hàng của bạn.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'Xem chi tiết hóa đơn', onPressed: () {}),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.support_agent), label: const Text('Liên hệ hỗ trợ')),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedIndex: 3),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.title, required this.time, required this.subtitle, this.active = false, this.last = false});

  final String title;
  final String time;
  final String subtitle;
  final bool active;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(radius: 14, backgroundColor: active ? AppColors.secondary : const Color(0xFFD7CDD0), child: Icon(active ? Icons.local_shipping : Icons.circle, size: active ? 14 : 8, color: active ? Colors.white : AppColors.textSecondary)),
              if (!last) Expanded(child: Container(width: 2, color: const Color(0xFFD7CDD0))),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title, style: AppTextStyles.subtitle.copyWith(color: active ? AppColors.secondary : AppColors.primary))),
                      Text(time, style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: AppTextStyles.body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
