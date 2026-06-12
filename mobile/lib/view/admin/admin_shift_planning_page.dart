import 'package:flutter/material.dart';

import '../../controller/admin/admin_catalog_controller.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../model/admin/admin_lookup_model.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminShiftPlanningPage extends StatefulWidget {
  const AdminShiftPlanningPage({super.key});

  @override
  State<AdminShiftPlanningPage> createState() => _AdminShiftPlanningPageState();
}

class _AdminShiftPlanningPageState extends State<AdminShiftPlanningPage> {
  late final AdminCatalogController _controller = AdminCatalogController(
    adminCatalogRepository: AppDependencies.instance.adminCatalogRepository,
  );
  final Map<String, Set<String>> _shiftsByUserId = {};

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadUsers();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<AdminUserModel> get _staffUsers {
    return _controller.users.where((user) {
      final role = user.roleName.toUpperCase();
      return role == 'SHOP_STAFF' ||
          role == 'DELIVERY_STAFF' ||
          role == 'SHIPPER' ||
          role == 'STAFF';
    }).toList();
  }

  void _toggleShift(AdminUserModel user, String shift, bool selected) {
    setState(() {
      final shifts = _shiftsByUserId.putIfAbsent(user.id, () => <String>{});
      if (selected) {
        shifts.add(shift);
      } else {
        shifts.remove(shift);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _controller.loadUsers,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Backend chưa có API lưu ca trực, lịch hiện đang lưu tạm trên màn hình.',
              ),
            ),
          );
        },
        child: const Icon(Icons.save_outlined),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 3),
    );
  }

  Widget _buildBody() {
    final staffUsers = _staffUsers;
    if (_controller.isLoading && staffUsers.isEmpty) {
      return const AppLoadingState(title: 'Đang tải lịch ca');
    }
    if (_controller.errorMessage != null && staffUsers.isEmpty) {
      return AppErrorState(
        title: 'Không tải được nhân viên',
        message: _controller.errorMessage!,
        onAction: _controller.loadUsers,
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const _Header(),
        const SizedBox(height: AppSpacing.xl),
        const _DateStrip(),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            const Expanded(
              child: Text(
                'DANH SÁCH NHÂN SỰ',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Text(
              '${staffUsers.length} thành viên',
              style: const TextStyle(color: AppColors.secondary, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (staffUsers.isEmpty)
          const AppEmptyState(
            title: 'Chưa có nhân viên',
            message: 'Tạo user SHOP_STAFF hoặc DELIVERY_STAFF để xếp ca.',
          )
        else
          ...staffUsers.map(
            (user) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _ShiftCard(
                user: user,
                shifts: _shiftsByUserId[user.id] ?? const <String>{},
                onShiftChanged: (shift, selected) =>
                    _toggleShift(user, shift, selected),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Ghi chú: backend chưa có endpoint lịch làm việc, nên các ca đang chọn chỉ lưu tạm trong phiên hiện tại.',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lập lịch ca trực',
                style: AppTextStyles.display.copyWith(fontSize: 38),
              ),
              Text(
                'Xếp ca cho SHOP_STAFF và DELIVERY_STAFF.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 34,
          backgroundColor: AppColors.surfaceMuted,
          child: const Icon(Icons.calendar_month, color: AppColors.primary),
        ),
      ],
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(6, (index) => now.add(Duration(days: index)));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days
              .map(
                (day) => _Day(
                  label: 'T${day.weekday + 1}',
                  day: '${day.day}',
                  active: day.day == now.day,
                ),
              )
              .toList(),
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
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: active ? Border.all(color: AppColors.primary, width: 3) : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
          Text(
            day,
            style: AppTextStyles.title.copyWith(
              color: active ? Colors.white : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({
    required this.user,
    required this.shifts,
    required this.onShiftChanged,
  });

  final AdminUserModel user;
  final Set<String> shifts;
  final void Function(String shift, bool selected) onShiftChanged;

  @override
  Widget build(BuildContext context) {
    final accent = user.status ? AppColors.success : AppColors.textSecondary;
    final statusText = user.status ? 'SẴN SÀNG' : 'NGỪNG HOẠT ĐỘNG';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.surfaceMuted,
                  foregroundColor: accent,
                  child: const Icon(Icons.person),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName, style: AppTextStyles.title),
                      Text(
                        user.roleName,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(statusText),
                  backgroundColor: accent.withValues(alpha: 0.14),
                  labelStyle: TextStyle(color: accent),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _ShiftChip(
                  label: 'CA SÁNG',
                  selected: shifts.contains('MORNING'),
                  enabled: user.status,
                  onSelected: (selected) => onShiftChanged('MORNING', selected),
                ),
                const SizedBox(width: AppSpacing.md),
                _ShiftChip(
                  label: 'CA CHIỀU',
                  selected: shifts.contains('AFTERNOON'),
                  enabled: user.status,
                  onSelected: (selected) =>
                      onShiftChanged('AFTERNOON', selected),
                ),
                const SizedBox(width: AppSpacing.md),
                _ShiftChip(
                  label: 'CA TỐI',
                  selected: shifts.contains('NIGHT'),
                  enabled: user.status,
                  onSelected: (selected) => onShiftChanged('NIGHT', selected),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShiftChip extends StatelessWidget {
  const _ShiftChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilterChip(
        selected: selected,
        onSelected: enabled ? onSelected : null,
        label: SizedBox(
          width: double.infinity,
          child: Text(label, textAlign: TextAlign.center),
        ),
        selectedColor: AppColors.secondary,
        disabledColor: AppColors.surfaceMuted.withValues(alpha: 0.4),
        backgroundColor: AppColors.surfaceMuted,
        labelStyle: AppTextStyles.body.copyWith(
          color: selected ? Colors.white : AppColors.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
