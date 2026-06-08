import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../admin/widgets/admin_app_bar.dart';

class ShopStaffHandoverPage extends StatelessWidget {
  const ShopStaffHandoverPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const AdminAppBar(),
        body: ListView(padding: const EdgeInsets.all(AppSpacing.lg), children: const [
          _Header(),
          SizedBox(height: AppSpacing.xl),
          Text('🚚  CHỌN NHÂN VIÊN GIAO HÀNG', style: TextStyle(fontWeight: FontWeight.w900)),
          SizedBox(height: AppSpacing.sm),
          TextField(readOnly: true, decoration: InputDecoration(hintText: 'Chọn đối tác vận chuyển...', suffixIcon: Icon(Icons.keyboard_arrow_down))),
          SizedBox(height: AppSpacing.xl),
          Row(children: [Expanded(child: Text('📦  ĐƠN HÀNG SẴN SÀNG (04)', style: TextStyle(fontWeight: FontWeight.w900))), Text('CHỌN TẤT CẢ', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900))]),
          SizedBox(height: AppSpacing.md),
          _ReadyOrder(code: '#AV-8829', name: 'Apex Velocity Pro-Run V2', price: '1.250.000đ', icon: Icons.directions_run),
          _ReadyOrder(code: '#AV-8830', name: 'Apex Stealth Watch Edition', price: '3.400.000đ', icon: Icons.watch_outlined),
          _ReadyOrder(code: '#AV-8831', name: 'Aero-Carbon Performance', price: '5.100.000đ', icon: Icons.sports_football_outlined),
          SizedBox(height: AppSpacing.xl),
          Text('GHI CHÚ BÀN GIAO', style: TextStyle(fontWeight: FontWeight.w900)),
          SizedBox(height: AppSpacing.sm),
          TextField(minLines: 4, maxLines: 5, decoration: InputDecoration(hintText: 'Nhập lưu ý cho đơn vị vận chuyển (ví dụ: hàng dễ vỡ, cần giao trong sáng nay)...')),
          SizedBox(height: 120),
        ]),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [Text('Đã chọn: ', style: AppTextStyles.caption), Text('3 đơn hàng', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900)), const Spacer(), Text('Tổng cộng: ', style: AppTextStyles.caption), Text('9.750.000đ', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900))]),
              const SizedBox(height: AppSpacing.md),
              AppButton(label: 'BÀN GIAO GIAO HÀNG', variant: AppButtonVariant.secondary, icon: Icons.local_shipping_outlined, onPressed: null),
            ]),
          ),
        ),
      );
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Bàn giao vận chuyển', style: AppTextStyles.display.copyWith(fontSize: 30)), Text('Kiểm tra và xác nhận bàn giao các đơn hàng đã đóng gói cho đơn vị vận chuyển.', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))]);
}

class _ReadyOrder extends StatelessWidget {
  const _ReadyOrder({required this.code, required this.name, required this.price, required this.icon});
  final String code; final String name; final String price; final IconData icon;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: AppSpacing.md), padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)), child: Row(children: [Container(width: 82, height: 82, decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.sm)), child: Icon(icon, color: AppColors.secondary)), const SizedBox(width: AppSpacing.lg), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(code, style: AppTextStyles.body), Text(name, maxLines: 1, overflow: TextOverflow.ellipsis), Text(price, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900))])), const Chip(label: Text('PACKING')), const SizedBox(width: AppSpacing.sm), const Icon(Icons.check_box, color: AppColors.secondary)]));
}
