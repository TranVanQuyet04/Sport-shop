import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/chat/chat_controller.dart' as app_chat;
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_text_styles.dart';
import '../../model/chat/chat_model.dart';
import '../../widgets/shared/absolute_persistent_layout.dart';
import '../../core/widgets/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';
import 'widgets/admin_design_system.dart';

class AdminChatRoomsPage extends StatefulWidget {
  const AdminChatRoomsPage({super.key});

  @override
  State<AdminChatRoomsPage> createState() => _AdminChatRoomsPageState();
}

class _AdminChatRoomsPageState extends State<AdminChatRoomsPage> {
  late final app_chat.ChatController _controller;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = app_chat.ChatController(
      chatRepository: AppDependencies.instance.chatRepository,
    );
    _controller.addListener(_onControllerChanged);
    _controller.loadAdminRooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
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
        onRefresh: _controller.loadAdminRooms,
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
              if (_controller.isLoading)
                const AppLoadingState(message: 'Đang tải phòng chat...')
              else if (_controller.errorMessage != null &&
                  _controller.rooms.isEmpty)
                AppErrorState(
                  message: 'Chưa tải được phòng chat từ backend.',
                  onAction: _controller.loadAdminRooms,
                )
              else ...[
                if (_controller.errorMessage != null) ...[
                  AdminInlineBanner(
                    message: _controller.errorMessage!,
                    isError: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (visibleRooms.isEmpty)
                  PremiumEmptyState(
                    icon: _controller.rooms.isEmpty
                        ? Icons.forum_outlined
                        : Icons.search_off_rounded,
                    title: _controller.rooms.isEmpty
                        ? 'Chưa có phòng chat'
                        : 'Không tìm thấy phòng chat',
                    message: _controller.rooms.isEmpty
                        ? 'Khi khách hàng tạo yêu cầu hỗ trợ, phòng chat sẽ xuất hiện ở đây.'
                        : 'Hãy thử thay đổi từ khóa tìm kiếm hiện tại.',
                    actionLabel: _controller.rooms.isEmpty
                        ? 'Tải lại dữ liệu'
                        : 'Xóa tìm kiếm',
                    onAction: _controller.rooms.isEmpty
                        ? _controller.loadAdminRooms
                        : () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                  )
                else
                  ...visibleRooms.map(
                    (room) => _ChatRoomTile(
                      room: room,
                      onTap: () => context.go('/admin/chats/${room.id}'),
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
    if (query.isEmpty) {
      return _controller.rooms;
    }
    return _controller.rooms.where((room) {
      return room.id.toLowerCase().contains(query) ||
          room.customerName.toLowerCase().contains(query) ||
          room.adminName.toLowerCase().contains(query);
    }).toList();
  }
}

class _ChatRoomTile extends StatelessWidget {
  const _ChatRoomTile({required this.room, required this.onTap});

  final ChatRoomModel room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AdminOutlinedSurface(
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: onTap,
        child: Row(
          children: [
            const AdminIconBadge(icon: Icons.person_outline),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    room.adminName.isEmpty
                        ? 'Chưa có nhân viên phụ trách'
                        : 'Admin: ${room.adminName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AdminColors.textSecondary,
                    ),
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
}
