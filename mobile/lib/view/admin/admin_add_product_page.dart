import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

class AdminAddProductPage extends StatelessWidget {
  const AdminAddProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: context.pop, icon: const Icon(Icons.arrow_back)),
        title: const Text('Thêm sản phẩm mới'),
        actions: [IconButton(onPressed: context.pop, icon: const Icon(Icons.close))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _StepperHeader(),
          SizedBox(height: AppSpacing.xl),
          _CoverPicker(),
          SizedBox(height: AppSpacing.xl),
          _FormIntro(),
          SizedBox(height: AppSpacing.xl),
          _LabeledInput(label: 'TÊN SẢN PHẨM *', hint: 'Ví dụ: Giày Chạy Apex Pro V1'),
          _LabeledInput(label: 'MÃ SKU *', hint: 'APX-RUN-2024-001', suffixIcon: Icons.qr_code_scanner),
          _LabeledInput(label: 'THƯƠNG HIỆU', hint: 'Chọn thương hiệu', suffixIcon: Icons.keyboard_arrow_down),
          Row(children: [
            Expanded(child: _LabeledInput(label: 'DANH MỤC', hint: 'Chọn', suffixIcon: Icons.keyboard_arrow_down)),
            SizedBox(width: AppSpacing.md),
            Expanded(child: _LabeledInput(label: 'MÔN THỂ THAO', hint: 'Chọn', suffixIcon: Icons.keyboard_arrow_down)),
          ]),
          _TipBox(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(label: 'TIẾP THEO  →', variant: AppButtonVariant.secondary, onPressed: () {}),
        ),
      ),
    );
  }
}

class _StepperHeader extends StatelessWidget {
  const _StepperHeader();

  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      _StepCircle(number: '1', label: 'Cơ bản', active: true),
      Expanded(child: Divider(color: AppColors.secondary)),
      _StepCircle(number: '2', label: 'Chi tiết'),
      Expanded(child: Divider()),
      _StepCircle(number: '3', label: 'Hình ảnh'),
    ]);
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({required this.number, required this.label, this.active = false});

  final String number;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(backgroundColor: active ? AppColors.secondary : AppColors.surfaceMuted, foregroundColor: active ? Colors.white : AppColors.primary, child: Text(number)),
      const SizedBox(height: AppSpacing.sm),
      Text(label, style: AppTextStyles.caption.copyWith(color: active ? AppColors.secondary : AppColors.primary, fontWeight: FontWeight.w900)),
    ]);
  }
}

class _CoverPicker extends StatelessWidget {
  const _CoverPicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add_a_photo, size: 54), SizedBox(height: AppSpacing.md), Text('ẢNH BÌA SẢN PHẨM (TÙY CHỌN)', style: TextStyle(fontWeight: FontWeight.w900))])),
    );
  }
}

class _FormIntro extends StatelessWidget {
  const _FormIntro();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Thông tin chung', style: AppTextStyles.display.copyWith(fontSize: 34)), const SizedBox(height: AppSpacing.sm), Text('Vui lòng cung cấp các chi tiết cơ bản để nhận diện sản phẩm trong hệ thống.', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 18))]);
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({required this.label, required this.hint, this.suffixIcon});
  final String label; final String hint; final IconData? suffixIcon;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.lg), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)), const SizedBox(height: AppSpacing.sm), TextField(decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon == null ? null : Icon(suffixIcon)))]));
}

class _TipBox extends StatelessWidget {
  const _TipBox();
  @override
  Widget build(BuildContext context) => DecoratedBox(decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.lg), border: const Border(left: BorderSide(color: AppColors.secondary, width: 4))), child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.lightbulb_outline, color: AppColors.secondary), const SizedBox(width: AppSpacing.md), Expanded(child: Text('Mẹo nhỏ cho bạn\nSử dụng tên sản phẩm bao gồm Loại sản phẩm + Dòng máy + Đặc tính nổi bật để tăng khả năng tìm kiếm của khách hàng.', style: AppTextStyles.body))])));
}
