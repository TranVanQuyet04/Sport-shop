import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminChatRoomsPage extends StatelessWidget {
  const AdminChatRoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Hỗ trợ trực tuyến', style: AppTextStyles.display.copyWith(fontSize: 34)),
          const SizedBox(height: AppSpacing.md),
          const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Tìm phòng chat, khách hàng...')),
          const SizedBox(height: AppSpacing.xl),
          _ChatRoom(name: 'Hoàng Anh', message: 'Mình muốn hỏi về size áo khoác...', unread: 3, onTap: () => context.go('/admin/chats/room-1')),
          _ChatRoom(name: 'Nguyễn Minh', message: 'Đơn hàng của mình đang ở đâu?', unread: 1, onTap: () => context.go('/admin/chats/room-2')),
          _ChatRoom(name: 'Lan Phạm', message: 'Cảm ơn shop đã hỗ trợ.', unread: 0, onTap: () => context.go('/admin/chats/room-3')),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 4),
    );
  }
}

class _ChatRoom extends StatelessWidget {
  const _ChatRoom({required this.name, required this.message, required this.unread, required this.onTap});
  final String name;
  final String message;
  final int unread;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        leading: const CircleAvatar(radius: 30, child: Icon(Icons.person)),
        title: Text(name, style: AppTextStyles.subtitle),
        subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: unread > 0 ? CircleAvatar(radius: 14, backgroundColor: AppColors.secondary, child: Text('$unread', style: const TextStyle(color: Colors.white))) : const Icon(Icons.chevron_right),
      );
}
