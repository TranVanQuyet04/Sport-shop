import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class CustomerSupportPage extends StatelessWidget {
  const CustomerSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Trung tâm hỗ trợ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Bạn cần hỗ trợ gì?',
            style: AppTextStyles.display.copyWith(fontSize: 30),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tìm câu trả lời nhanh hoặc nhắn tin với hỗ trợ viên Sportshop.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppTextField(
            label: 'Tìm kiếm',
            prefixIcon: Icons.search,
            hintText: 'Nhập câu hỏi hoặc mã đơn hàng...',
          ),
          const SizedBox(height: AppSpacing.xl),
          _PrioritySupportCard(
            onChat: () => context.go(AppRoutes.customerChat),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Chủ đề hỗ trợ', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          const _SupportTile(
            icon: Icons.local_shipping_outlined,
            title: 'Vận chuyển và giao hàng',
            subtitle: 'Theo dõi đơn, đổi lịch giao, giao thất bại',
          ),
          const _SupportTile(
            icon: Icons.payment_outlined,
            title: 'Thanh toán',
            subtitle: 'COD, VNPay, ví điện tử, hoàn tiền',
          ),
          const _SupportTile(
            icon: Icons.assignment_return_outlined,
            title: 'Đổi trả sản phẩm',
            subtitle: 'Chính sách đổi size, lỗi sản phẩm, hoàn trả',
          ),
          const _SupportTile(
            icon: Icons.person_outline,
            title: 'Tài khoản',
            subtitle: 'Đăng nhập, bảo mật, thông tin cá nhân',
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Câu hỏi thường gặp', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          const _FaqTile(
            question: 'Tôi có thể đổi size sau khi nhận hàng không?',
            answer:
                'Có. Bạn có thể gửi yêu cầu đổi size trong vòng 7 ngày nếu sản phẩm còn nguyên tem và chưa qua sử dụng.',
          ),
          const _FaqTile(
            question: 'Làm sao để theo dõi đơn hàng?',
            answer:
                'Vào mục Đơn hàng, chọn đơn cần xem và bấm Theo dõi để xem timeline giao hàng.',
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _PrioritySupportCard extends StatelessWidget {
  const _PrioritySupportCard({required this.onChat});

  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.support_agent_outlined,
              color: AppColors.textInverse,
              size: 36,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Cần xử lý gấp?',
              style: AppTextStyles.title.copyWith(color: AppColors.textInverse),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Hỗ trợ viên có thể kiểm tra đơn hàng, thanh toán và trạng thái giao hàng cho bạn.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textInverse.withValues(alpha: 0.76),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Nhắn tin ngay',
              icon: Icons.chat_bubble_outline,
              variant: AppButtonVariant.secondary,
              onPressed: onChat,
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          leading: CircleAvatar(
            backgroundColor: AppColors.surfaceMuted,
            foregroundColor: AppColors.primary,
            child: Icon(icon),
          ),
          title: Text(title, style: AppTextStyles.subtitle),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          title: Text(question, style: AppTextStyles.subtitle),
          children: [
            Text(
              answer,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
