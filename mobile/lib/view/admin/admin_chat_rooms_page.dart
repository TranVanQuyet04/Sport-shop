import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../model/chat/chat_model.dart';
import '../../presenter/chat/chat_presenter.dart' as app_chat;
import '../../widgets/shared/absolute_persistent_layout.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

class AdminChatRoomsPage extends StatefulWidget {
  const AdminChatRoomsPage({super.key});

  @override
  State<AdminChatRoomsPage> createState() => _AdminChatRoomsPageState();
}

class _AdminChatRoomsPageState extends State<AdminChatRoomsPage> {
  late final app_chat.ChatPresenter _presenter;
  final TextEditingController _searchController = TextEditingController();
  Timer? _refreshTimer;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _presenter = app_chat.ChatPresenter(
      chatRepository: AppDependencies.instance.chatRepository,
    );
    _presenter.addListener(_onControllerChanged);
    _presenter.loadAdminRooms();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _presenter.loadAdminRooms(silent: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    _presenter.removeListener(_onControllerChanged);
    _presenter.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleRooms = _visibleRooms;
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _presenter.loadAdminRooms,
        child: AbsolutePersistentLayout(
          title: 'Hỗ trợ trực tuyến',
          subtitle: 'Theo dõi và phản hồi các cuộc trò chuyện của khách hàng.',
          icon: Icons.support_agent_outlined,
          filterAndSearchZone: AppTextField(
            label: 'Tìm kiếm',
            controller: _searchController,
            prefixIcon: Icons.search,
            hintText: 'Tìm phòng chat, khách hàng...',
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          dynamicContent: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              0,
            ),
            children: [
              if (_presenter.isLoading && _presenter.rooms.isEmpty)
                const AppLoadingState(message: 'Đang tải phòng chat...')
              else if (_presenter.errorMessage != null &&
                  _presenter.rooms.isEmpty)
                AppErrorState(
                  message: 'Chưa tải được phòng chat từ backend.',
                  onAction: _presenter.loadAdminRooms,
                )
              else ...[
                if (_presenter.errorMessage != null) ...[
                  AdminInlineBanner(
                    message: _presenter.errorMessage!,
                    isError: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (visibleRooms.isEmpty)
                  PremiumEmptyState(
                    icon: _presenter.rooms.isEmpty
                        ? Icons.forum_outlined
                        : Icons.search_off_rounded,
                    title: _presenter.rooms.isEmpty
                        ? 'Chưa có phòng chat'
                        : 'Không tìm thấy phòng chat',
                    message: _presenter.rooms.isEmpty
                        ? 'Khi khách hàng tạo yêu cầu hỗ trợ, phòng chat sẽ xuất hiện ở đây.'
                        : 'Hãy thử thay đổi từ khóa tìm kiếm hiện tại.',
                    actionLabel: _presenter.rooms.isEmpty
                        ? 'Tải lại dữ liệu'
                        : 'Xóa tìm kiếm',
                    onAction: _presenter.rooms.isEmpty
                        ? _presenter.loadAdminRooms
                        : () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                  )
                else
                  ...visibleRooms.map(
                    (room) => _ChatRoomTile(
                      room: room,
                      latestMessage: _presenter.latestMessagesByRoomId[room.id],
                      onTap: () => context.go(
                        AppRoutes.adminChatDetail.replaceFirst(':id', room.id),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 4),
    );
  }

  List<ChatRoomModel> get _visibleRooms {
    final query = _searchQuery.trim().toLowerCase();
    final rooms = query.isEmpty
        ? [..._presenter.rooms]
        : _presenter.rooms.where((room) {
            final latest = _presenter.latestMessagesByRoomId[room.id];
            return room.id.toLowerCase().contains(query) ||
                room.customerName.toLowerCase().contains(query) ||
                room.adminName.toLowerCase().contains(query) ||
                (latest?.content.toLowerCase().contains(query) ?? false);
          }).toList();

    rooms.sort((a, b) {
      final aLatest = _presenter.latestMessagesByRoomId[a.id];
      final bLatest = _presenter.latestMessagesByRoomId[b.id];
      final aTime =
          aLatest?.sentAt ??
          a.lastMessageAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bTime =
          bLatest?.sentAt ??
          b.lastMessageAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return rooms;
  }
}

class _ChatRoomTile extends StatelessWidget {
  const _ChatRoomTile({
    required this.room,
    required this.latestMessage,
    required this.onTap,
  });

  final ChatRoomModel room;
  final ChatMessageModel? latestMessage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _ChatRoomStatus.from(room, latestMessage);
    final preview = latestMessage?.content.trim().isNotEmpty == true
        ? latestMessage!.content.trim()
        : 'Chưa có tin nhắn';
    final time = latestMessage?.sentAt ?? room.lastMessageAt;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AdminOutlinedSurface(
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminIconBadge(icon: Icons.person_outline),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.subtitle.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StatusPill(status: status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AdminColors.textSecondary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatLastMessageAt(time),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: time == null
                                ? AdminColors.textSecondary
                                : AdminColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        room.adminName.isEmpty
                            ? 'Chưa gán admin'
                            : 'Admin: ${room.adminName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AdminColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (room.hasUnread)
              const CircleAvatar(
                radius: 14,
                backgroundColor: AdminColors.accent,
                child: Text('!', style: TextStyle(color: Colors.white)),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: AdminColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  String _formatLastMessageAt(DateTime? value) {
    if (value == null) {
      return 'Chưa có tin nhắn';
    }

    final time = value.toLocal();
    final now = DateTime.now();
    final diff = now.difference(time);
    if (!diff.isNegative && diff.inSeconds < 60) {
      return 'Vừa xong';
    }
    if (!diff.isNegative && diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    }

    final sameDay =
        time.year == now.year && time.month == now.month && time.day == now.day;
    if (sameDay) {
      return 'Hôm nay ${DateFormat('HH:mm').format(time)}';
    }

    return DateFormat('dd/MM HH:mm').format(time);
  }
}

enum _ChatRoomStatus {
  newRequest('Mới', AdminColors.accent),
  inProgress('Đang xử lý', AdminColors.orange),
  replied('Đã phản hồi', AdminColors.success);

  const _ChatRoomStatus(this.label, this.color);

  final String label;
  final Color color;

  factory _ChatRoomStatus.from(
    ChatRoomModel room,
    ChatMessageModel? latestMessage,
  ) {
    if (room.hasUnread || latestMessage?.sender.toUpperCase() == 'CUSTOMER') {
      return _ChatRoomStatus.newRequest;
    }
    if (latestMessage?.sender.toUpperCase() == 'ADMIN') {
      return _ChatRoomStatus.replied;
    }
    return _ChatRoomStatus.inProgress;
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final _ChatRoomStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: status.color.withValues(alpha: 0.28)),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.caption.copyWith(
          color: status.color,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }
}
