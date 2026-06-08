import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

class CustomerSupportPage extends StatelessWidget {
  const CustomerSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: context.pop, icon: const Icon(Icons.arrow_back)),
        title: const Text('Trung tâm hỗ trợ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Bạn cần hỗ trợ gì?', style: AppTextStyles.display.copyWith(fontSize: 30)),
          const SizedBox(height: AppSpacing.lg),
          const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Tìm câu hỏi hoặc mã đơn hàng')),
          const SizedBox(height: AppSpacing.xl),
          const _SupportTile(icon: Icons.local_shipping_outlined, title: 'Vận chuyển và giao hàng', subtitle: 'Theo dõi, đổi lịch, giao thất bại'),
          const _SupportTile(icon: Icons.payment_outlined, title: 'Thanh toán', subtitle: 'COD, chuyển khoản, hoàn tiền'),
          const _SupportTile(icon: Icons.assignment_return_outlined, title: 'Đổi trả sản phẩm', subtitle: 'Chính sách, yêu cầu đổi trả'),
          const _SupportTile(icon: Icons.person_outline, title: 'Tài khoản', subtitle: 'Đăng nhập, bảo mật, thông tin cá nhân'),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'Nhắn tin với hỗ trợ viên', variant: AppButtonVariant.secondary, onPressed: () => context.go(AppRoutes.customerChat)),
        ],
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      leading: CircleAvatar(backgroundColor: AppColors.surfaceMuted, foregroundColor: AppColors.primary, child: Icon(icon)),
      title: Text(title, style: AppTextStyles.subtitle),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
