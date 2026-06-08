import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class SharedFormDemoPage extends StatelessWidget {
  const SharedFormDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shared Form')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Form dùng chung', style: AppTextStyles.display.copyWith(fontSize: 30)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Dùng các widget này cho login, register, checkout, filter và report.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppTextField(
            label: 'Email',
            hintText: 'Nhập email của bạn',
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            helperText: 'Ví dụ: customer@sportshop.vn',
          ),
          const SizedBox(height: AppSpacing.lg),
          const AppTextField(
            label: 'Mật khẩu',
            hintText: 'Nhập mật khẩu',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          const AppTextField(
            label: 'Số điện thoại',
            hintText: 'Nhập số điện thoại',
            prefixIcon: Icons.phone_outlined,
            errorText: 'Số điện thoại chưa đúng định dạng.',
          ),
          const SizedBox(height: AppSpacing.lg),
          const AppTextField(
            label: 'Ghi chú giao hàng',
            hintText: 'Nhập ghi chú cho shipper...',
            prefixIcon: Icons.notes_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Mở bottom sheet lọc',
            icon: Icons.tune,
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      title: 'Bộ lọc sản phẩm',
      subtitle: 'Chọn điều kiện để thu hẹp danh sách sản phẩm.',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Thương hiệu'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              Chip(label: Text('Nike')),
              Chip(label: Text('adidas')),
              Chip(label: Text('Puma')),
              Chip(label: Text('Under Armour')),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          _SectionTitle('Khoảng giá'),
          AppTextField(
            label: 'Giá tối đa',
            hintText: 'Ví dụ: 2.000.000đ',
            prefixIcon: Icons.payments_outlined,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        AppButton(label: 'Áp dụng lọc', onPressed: () => Navigator.of(context).pop()),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Xóa bộ lọc',
          variant: AppButtonVariant.outline,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(text, style: AppTextStyles.subtitle),
    );
  }
}
