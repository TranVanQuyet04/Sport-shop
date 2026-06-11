import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/chat/chat_controller.dart' as app_chat;
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../model/chat/chat_model.dart';

class AdminChatDetailPage extends StatefulWidget {
  const AdminChatDetailPage({super.key, required this.chatId});

  final String chatId;

  @override
  State<AdminChatDetailPage> createState() => _AdminChatDetailPageState();
}

class _AdminChatDetailPageState extends State<AdminChatDetailPage> {
  late final app_chat.ChatController _controller;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = app_chat.ChatController(
      chatRepository: AppDependencies.instance.chatRepository,
    );
    _controller.messages = const [
      ChatMessageModel(
        id: 'admin-hint',
        content:
            'Backend hiện chưa có API lấy lịch sử tin nhắn theo phòng. Tin nhắn mới sẽ hiển thị sau khi gửi.',
        sender: 'SYSTEM',
        sentAt: null,
      ),
    ];
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _controller.isSending) {
      return;
    }
    _messageController.clear();
    await _controller.sendRoomMessage(
      roomId: widget.chatId,
      content: text,
      sender: 'ADMIN',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Phòng #${widget.chatId}\nĐang hỗ trợ',
                style: AppTextStyles.subtitle,
              ),
            ),
          ],
        ),
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.call_outlined)),
          IconButton(onPressed: null, icon: Icon(Icons.videocam_outlined)),
        ],
      ),
      body: Column(
        children: [
          if (_controller.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Text(
                'Chưa gửi được tin nhắn vào phòng chat.',
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _controller.messages.length,
              itemBuilder: (context, index) {
                final message = _controller.messages[index];
                return _Bubble(
                  text: message.content,
                  fromMe: message.sender.toUpperCase() == 'ADMIN',
                  isSystem: message.sender.toUpperCase() == 'SYSTEM',
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  CircleAvatar(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    child: IconButton(
                      onPressed: _controller.isSending ? null : _sendMessage,
                      icon: _controller.isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.fromMe,
    required this.isSystem,
  });

  final String text;
  final bool fromMe;
  final bool isSystem;

  @override
  Widget build(BuildContext context) {
    if (isSystem) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return Align(
      alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: fromMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Text(
          text,
          style: AppTextStyles.body.copyWith(
            color: fromMe ? Colors.white : AppColors.primary,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}
