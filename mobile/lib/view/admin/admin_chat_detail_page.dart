import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../controller/chat/chat_controller.dart' as app_chat;
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/hover_effect.dart';
import 'widgets/admin_design_system.dart';

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
    _controller.addListener(_onControllerChanged);
    _controller.loadRoomMessages(widget.chatId);
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

  void _closePage() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.adminChatRooms);
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
          onPressed: _closePage,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Room #${widget.chatId}\nSupport chat',
                style: AppTextStyles.subtitle,
              ),
            ),
          ],
        ),
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
                'Could not load or send chat messages.',
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ),
          if (_controller.isLoading)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _controller.messages.isEmpty && !_controller.isLoading
                ? Center(
                    child: Text(
                      'Chưa có tin nhắn.',
                      style: AppTextStyles.body.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = _controller.messages[index];
                      return _Bubble(
                        text: message.content,
                        fromMe: message.sender.toUpperCase() == 'ADMIN',
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  HoverLift(
                    interactive: !_controller.isSending,
                    scale: 1.06,
                    dy: -1,
                    borderRadius: BorderRadius.circular(999),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      child: IconButton(
                        onPressed: _controller.isSending ? null : _sendMessage,
                        icon: _controller.isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                      ),
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
  const _Bubble({required this.text, required this.fromMe});

  final String text;
  final bool fromMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: HoverLift(
        scale: 1.008,
        dy: -1,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 330),
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: fromMe ? AdminColors.primary : AdminColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: fromMe ? null : AdminDesign.cardShadow,
          ),
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: fromMe ? Colors.white : AdminColors.primary,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }
}
