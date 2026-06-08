import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminLeaveManagementPage extends StatelessWidget {
  const AdminLeaveManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), actions: const [IconButton(onPressed: null, icon: Icon(Icons.notifications_none))]),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          _Title(),
          SizedBox(height: AppSpacing.xl),
          _CalendarCard(),
          SizedBox(height: AppSpacing.xl),
          Row(children: [Expanded(child: Text('Đang chờ duyệt', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))), Chip(label: Text('3 Yêu cầu'))]),
          SizedBox(height: AppSpacing.md),
          _LeaveRequest(name: 'Nguyễn Thu Hà', dept: 'Phòng Kinh doanh', date: '15 Th10', days: '1 ngày', reason: 'Nghỉ ốm (Cảm cúm theo mùa, cần đi khám bác sĩ).'),
          SizedBox(height: AppSpacing.lg),
          _LeaveRequest(name: 'Trần Minh Quân', dept: 'Phòng Kỹ thuật', date: '11 Th10', days: '2 ngày', reason: 'Việc gia đình riêng (Giải quyết thủ tục nhà đất).'),
          SizedBox(height: AppSpacing.xl),
          Text('Hoạt động gần đây', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          SizedBox(height: AppSpacing.md),
          _RecentLeave(name: 'Lê Văn Sâm', status: 'Đã duyệt - 05 Th10', ok: true),
          SizedBox(height: AppSpacing.md),
          _RecentLeave(name: 'Phạm Mỹ Linh', status: 'Từ chối - 04 Th10', ok: false),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Quản lý Nghỉ phép', style: AppTextStyles.display.copyWith(fontSize: 34)),
      Text('Tháng 10, 2023', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
    ]);
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard();

  @override
  Widget build(BuildContext context) {
    final days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', '27', '28', '29', '30', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17'];
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text('Tháng 10', style: AppTextStyles.title), const Spacer(), const Icon(Icons.chevron_left), const Icon(Icons.chevron_right)]),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: AppSpacing.md),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final active = days[index] == '14';
              return Center(child: Container(width: 42, height: 42, decoration: BoxDecoration(color: active ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(AppRadius.md)), child: Center(child: Text(days[index], style: TextStyle(color: active ? Colors.white : AppColors.primary, fontWeight: index < 7 ? FontWeight.w800 : FontWeight.w500)))));
            },
          ),
        ]),
      ),
    );
  }
}

class _LeaveRequest extends StatelessWidget {
  const _LeaveRequest({required this.name, required this.dept, required this.date, required this.days, required this.reason});

  final String name;
  final String dept;
  final String date;
  final String days;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(children: [
          Row(children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: AppTextStyles.subtitle), Text(dept)])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(date, style: AppTextStyles.subtitle), Text(days, style: AppTextStyles.body.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w900))]),
          ]),
          const SizedBox(height: AppSpacing.md),
          DecoratedBox(decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)), child: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: Align(alignment: Alignment.centerLeft, child: Text('Lý do: $reason')))),
          const SizedBox(height: AppSpacing.md),
          Row(children: [Expanded(child: AppButton(label: 'Từ chối', variant: AppButtonVariant.outline, onPressed: () {})), const SizedBox(width: AppSpacing.md), Expanded(child: AppButton(label: 'Duyệt', variant: AppButtonVariant.secondary, onPressed: () {}))]),
        ]),
      ),
    );
  }
}

class _RecentLeave extends StatelessWidget {
  const _RecentLeave({required this.name, required this.status, required this.ok});

  final String name;
  final String status;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border(left: BorderSide(color: ok ? AppColors.success : AppColors.secondary, width: 4))),
      child: ListTile(leading: Icon(ok ? Icons.check_circle_outline : Icons.cancel_outlined, color: ok ? AppColors.success : AppColors.secondary), title: Text(name, style: AppTextStyles.subtitle), subtitle: Text(status), trailing: const Icon(Icons.chevron_right)),
    );
  }
}
