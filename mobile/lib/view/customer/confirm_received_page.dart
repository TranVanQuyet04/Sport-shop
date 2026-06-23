import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../model/common/order_status.dart';

class ConfirmReceivedPage extends StatefulWidget {
  const ConfirmReceivedPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<ConfirmReceivedPage> createState() => _ConfirmReceivedPageState();
}

class _ConfirmReceivedPageState extends State<ConfirmReceivedPage> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Xác nhận nhận hàng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const Spacer(),
            const CircleAvatar(
              radius: 64,
              backgroundColor: Color(0xFFEFFBF3),
              child: Icon(
                Icons.inventory_2_outlined,
                color: AppColors.success,
                size: 72,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Bạn đã nhận đơn #${widget.orderId}?',
              style: AppTextStyles.display.copyWith(fontSize: 30),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sau khi xác nhận, đơn hàng sẽ chuyển sang trạng thái hoàn thành.',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            AppButton(
              label: 'Xác nhận đã nhận hàng',
              variant: AppButtonVariant.secondary,
              isLoading: _isSubmitting,
              onPressed: _confirmReceived,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Để sau',
              variant: AppButtonVariant.outline,
              onPressed: _isSubmitting ? null : context.pop,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReceived() async {
    setState(() => _isSubmitting = true);
    try {
      await AppDependencies.instance.orderRepository.updateStatus(
        orderId: widget.orderId,
        status: OrderStatus.completed.apiValue,
        asAdminOrShipper: false,
      );
      if (!mounted) {
        return;
      }
      await _showSuccessSheet();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showSuccessSheet() {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 64,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Hoàn tất đơn hàng', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Cảm ơn bạn đã xác nhận. Trạng thái đơn hàng đã được cập nhật từ backend.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Về đơn hàng',
                variant: AppButtonVariant.secondary,
                onPressed: () => context.go(AppRoutes.orders),
              ),
            ],
          ),
        );
      },
    );
  }
}
