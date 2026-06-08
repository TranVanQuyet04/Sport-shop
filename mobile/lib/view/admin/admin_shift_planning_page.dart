import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminShiftPlanningPage extends StatelessWidget {
  const AdminShiftPlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _Header(),
          SizedBox(height: AppSpacing.xl),
          _DateStrip(),
          SizedBox(height: AppSpacing.xl),
          Row(children: [
            Expanded(child: Text('DANH SÁCH NHÂN SỰ', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textSecondary))),
            Text('8 thành viên', style: TextStyle(color: AppColors.secondary, fontSize: 18)),
          ]),
          SizedBox(height: AppSpacing.lg),
          _ShiftCard(name: 'Trần Nhật Minh', role: 'Huấn luyện viên Trưởng', status: 'SẴN SÀNG', accent: AppColors.success, morning: true),
          SizedBox(height: AppSpacing.lg),
          _ShiftCard(name: 'Lê Phương Thảo', role: 'Chuyên viên Yoga', status: 'ĐANG BẬN', accent: AppColors.warning, afternoon: true, night: true),
          SizedBox(height: AppSpacing.lg),
          _ShiftCard(name: 'Nguyễn Hoàng Nam', role: 'Quản lý Cơ sở', status: 'NGHỈ PHÉP', accent: AppColors.textSecondary, disabled: true),
        ],
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, onPressed: () {}, child: const Icon(Icons.add)),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Lập lịch ca trực', style: AppTextStyles.display.copyWith(fontSize: 38)),
        Text('Quản lý đội ngũ vận động viên & nhân viên', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 20)),
      ])),
      CircleAvatar(radius: 34, backgroundColor: AppColors.surfaceMuted, child: const Icon(Icons.calendar_month, color: AppColors.primary)),
    ]);
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Day(label: 'T2', day: '12'),
            _Day(label: 'T3', day: '13'),
            _Day(label: 'T4', day: '14', active: true),
            _Day(label: 'T5', day: '15'),
            _Day(label: 'T6', day: '16'),
            _Day(label: 'T7', day: '17'),
          ],
        ),
      ),
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({required this.label, required this.day, this.active = false});

  final String label;
  final String day;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: active ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(AppRadius.md), border: active ? Border.all(color: AppColors.primary, width: 3) : null),
      child: Column(children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: active ? Colors.white : AppColors.textSecondary)),
        Text(day, style: AppTextStyles.title.copyWith(color: active ? Colors.white : AppColors.primary)),
      ]),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({required this.name, required this.role, required this.status, required this.accent, this.morning = false, this.afternoon = false, this.night = false, this.disabled = false});

  final String name;
  final String role;
  final String status;
  final Color accent;
  final bool morning;
  final bool afternoon;
  final bool night;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border(left: BorderSide(color: accent, width: 4))),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(children: [
          Row(children: [
            CircleAvatar(radius: 36, backgroundColor: AppColors.surfaceMuted, foregroundColor: accent, child: const Icon(Icons.person)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: AppTextStyles.title), Text(role, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))])),
            Chip(label: Text(status), backgroundColor: accent.withValues(alpha: 0.14), labelStyle: TextStyle(color: accent)),
          ]),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [
            _ShiftButton(label: 'CA SÁNG', active: morning, disabled: disabled),
            const SizedBox(width: AppSpacing.md),
            _ShiftButton(label: 'CA CHIỀU', active: afternoon, disabled: disabled),
            const SizedBox(width: AppSpacing.md),
            _ShiftButton(label: 'CA TỐI', active: night, disabled: disabled),
          ]),
        ]),
      ),
    );
  }
}

class _ShiftButton extends StatelessWidget {
  const _ShiftButton({required this.label, required this.active, required this.disabled});

  final String label;
  final bool active;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(color: disabled ? AppColors.surfaceMuted.withValues(alpha: 0.4) : active ? AppColors.secondary : AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Text(label, textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: active ? Colors.white : disabled ? AppColors.textSecondary : AppColors.primary)),
      ),
    );
  }
}
