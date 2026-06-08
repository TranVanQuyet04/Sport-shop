import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/status_badge.dart';
import 'widgets/customer_bottom_nav.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
        title: Text('ĐƠN HÀNG', style: AppTextStyles.display.copyWith(fontSize: 28)),
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.search)),
          IconButton(onPressed: null, icon: Icon(Icons.notifications_none)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _OrderTab(label: 'Tất cả', active: true),
                _OrderTab(label: 'Chờ xác nhận'),
                _OrderTab(label: 'Đang giao'),
                _OrderTab(label: 'Đã giao'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _OrderCard(
            code: '#SW99281',
            time: '14:20, 22 Tháng 05, 2024',
            title: 'Nike Air Zoom Pegasus',
            price: 2950000,
            statusLabel: 'CHỜ XÁC NHẬN',
            statusTone: StatusTone.neutral,
            primaryAction: 'Chi tiết',
            secondaryAction: 'Hủy đơn',
            onPrimary: () => context.go('/customer/orders/SW99281'),
          ),
          const SizedBox(height: AppSpacing.lg),
          _OrderCard(
            code: '#SW99105',
            time: '09:15, 20 Tháng 05, 2024',
            title: 'Garmin Forerunner 255',
            price: 16200000,
            statusLabel: 'ĐANG GIAO',
            statusTone: StatusTone.error,
            primaryAction: 'THEO DÕI HÀNH TRÌNH',
            onPrimary: () => context.go('/customer/orders/SW99105/tracking'),
          ),
          const SizedBox(height: AppSpacing.lg),
          _OrderCard(
            code: '#SW98850',
            time: '18:45, 15 Tháng 05, 2024',
            title: 'Nike Metcon 8 Training',
            price: 3400000,
            statusLabel: 'ĐÃ GIAO',
            statusTone: StatusTone.success,
            primaryAction: 'Đánh giá',
            secondaryAction: 'Mua lại',
            onPrimary: () => context.go('/customer/orders/SW98850/confirm-received'),
          ),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedIndex: 3),
    );
  }
}

class _OrderTab extends StatelessWidget {
  const _OrderTab({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900, color: active ? AppColors.primary : AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Container(width: 72, height: 3, color: active ? AppColors.primary : Colors.transparent),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.code,
    required this.time,
    required this.title,
    required this.price,
    required this.statusLabel,
    required this.statusTone,
    required this.primaryAction,
    this.secondaryAction,
    this.onPrimary,
  });

  final String code;
  final String time;
  final String title;
  final int price;
  final String statusLabel;
  final StatusTone statusTone;
  final String primaryAction;
  final String? secondaryAction;
  final VoidCallback? onPrimary;

  @override
  Widget build(BuildContext context) {
    final priceText = NumberFormat.decimalPattern('vi_VN').format(price);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MÃ ĐƠN: $code', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900)),
                      Text(time, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                StatusBadge(label: statusLabel, tone: statusTone),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: const Icon(Icons.directions_run, color: AppColors.secondary, size: 44),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.title),
                      Text('Size: 42 | Màu: Đỏ/Đen', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                      Text('$priceTextđ', style: AppTextStyles.subtitle),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            Row(
              children: [
                Text('Tổng thanh toán:', style: AppTextStyles.body),
                const Spacer(),
                Text('$priceTextđ', style: AppTextStyles.title.copyWith(color: AppColors.secondary)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                if (secondaryAction != null) ...[
                  Expanded(
                    child: AppButton(label: secondaryAction!, variant: AppButtonVariant.outline, onPressed: () {}),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: AppButton(label: primaryAction, onPressed: onPrimary ?? () {}),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
