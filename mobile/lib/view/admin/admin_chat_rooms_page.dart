import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/chat/chat_controller.dart' as app_chat;
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../model/chat/chat_model.dart';
import '../../core/widgets/app_state.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminChatRoomsPage extends StatefulWidget {
  const AdminChatRoomsPage({super.key});

  @override
  State<AdminChatRoomsPage> createState() => _AdminChatRoomsPageState();
}

class _AdminChatRoomsPageState extends State<AdminChatRoomsPage> {
  late final app_chat.ChatController _controller;

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
    return Scaffold(
      appBar: const AdminAppBar(),
      body: RefreshIndicator(
        onRefresh: _controller.loadAdminRooms,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Hỗ trợ trực tuyến',
              style: AppTextStyles.display.copyWith(fontSize: 34),
            ),
            const SizedBox(height: AppSpacing.md),
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Tìm phòng chat, khách hàng...',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_controller.isLoading)
              const AppLoadingState(message: 'Đang tải phòng chat...')
            else if (_controller.errorMessage != null)
              AppErrorState(
                message: 'Chưa tải được phòng chat từ backend.',
                onAction: _controller.loadAdminRooms,
              )
            else if (_controller.rooms.isEmpty)
              const AppEmptyState(
                title: 'Chưa có phòng chat',
                message:
                    'Khi khách hàng tạo yêu cầu hỗ trợ, phòng chat sẽ xuất hiện ở đây.',
              )
            else
              ..._controller.rooms.map(
                (room) => _ChatRoomTile(
                  room: room,
                  onTap: () => context.go('/admin/chats/${room.id}'),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 4),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  const _ChatRoomTile({required this.room, required this.onTap});

  final ChatRoomModel room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      leading: const CircleAvatar(radius: 30, child: Icon(Icons.person)),
      title: Text(room.customerName, style: AppTextStyles.subtitle),
      subtitle: Text(
        room.adminName.isEmpty
            ? 'Chưa có nhân viên phụ trách'
            : 'Admin: ${room.adminName}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: room.hasUnread
          ? const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.secondary,
              child: Text('!', style: TextStyle(color: Colors.white)),
            )
          : const Icon(Icons.chevron_right),
    );
  }
}
