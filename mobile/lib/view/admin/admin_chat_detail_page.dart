import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/sportshop_router.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/hover_effect.dart';
import '../../presenter/chat/chat_presenter.dart' as app_chat;
import 'widgets/admin_design_system.dart';

class AdminChatDetailPage extends StatefulWidget {
  const AdminChatDetailPage({super.key, required this.chatId});

  final String chatId;

  @override
  State<AdminChatDetailPage> createState() => _AdminChatDetailPageState();
}

class _AdminChatDetailPageState extends State<AdminChatDetailPage> {
  late final app_chat.ChatPresenter _presenter;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _refreshTimer;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _presenter = app_chat.ChatPresenter(
      chatRepository: AppDependencies.instance.chatRepository,
    );
    _presenter.addListener(_onControllerChanged);
    _presenter.loadRoomMessages(widget.chatId);
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _presenter.loadRoomMessages(widget.chatId, silent: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _presenter.removeListener(_onControllerChanged);
    _presenter.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }
    final nextMessageCount = _presenter.messages.length;
    final hasNewMessage = nextMessageCount > _lastMessageCount;
    _lastMessageCount = nextMessageCount;
    setState(() {});
    if (hasNewMessage || _isNearBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) {
      return true;
    }
    final position = _scrollController.position;
    return position.maxScrollExtent - position.pixels <= 96;
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
    if (text.isEmpty || _presenter.isSending) {
      return;
    }
    _messageController.clear();
    await _presenter.sendRoomMessage(
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
          tooltip: 'Quay l\u1ea1i',
          onPressed: _closePage,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Ph\u00f2ng #${widget.chatId}\nH\u1ed7 tr\u1ee3 kh\u00e1ch h\u00e0ng',
                style: AppTextStyles.subtitle,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_presenter.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Text(
                'Kh\u00f4ng t\u1ea3i ho\u1eb7c g\u1eedi \u0111\u01b0\u1ee3c tin nh\u1eafn.',
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ),
          if (_presenter.isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _presenter.messages.isEmpty && !_presenter.isLoading
                ? Center(
                    child: Text(
                      'Ch\u01b0a c\u00f3 tin nh\u1eafn.',
                      style: AppTextStyles.body.copyWith(
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _presenter.messages.length,
                    itemBuilder: (context, index) {
                      final message = _presenter.messages[index];
                      return _Bubble(
                        text: _AdminChatText.clean(message.content),
                        fromMe: message.sender.toUpperCase() == 'ADMIN',
                        sender: message.sender,
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
                        hintText: 'Nh\u1eadp tin nh\u1eafn...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  HoverLift(
                    interactive: !_presenter.isSending,
                    scale: 1.06,
                    dy: -1,
                    borderRadius: BorderRadius.circular(999),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      child: IconButton(
                        tooltip: 'G\u1eedi tin nh\u1eafn',
                        onPressed: _presenter.isSending ? null : _sendMessage,
                        icon: _presenter.isSending
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
  const _Bubble({
    required this.text,
    required this.fromMe,
    required this.sender,
  });

  final String text;
  final bool fromMe;
  final String sender;

  @override
  Widget build(BuildContext context) {
    final isBot = sender.toUpperCase() == 'BOT';

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
            border: isBot
                ? Border.all(color: AdminColors.action.withValues(alpha: 0.18))
                : null,
            boxShadow: fromMe ? null : AdminDesign.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBot) ...[
                Text(
                  'Bot h\u1ed7 tr\u1ee3',
                  style: AppTextStyles.caption.copyWith(
                    color: AdminColors.action,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              Text(
                text,
                style: AppTextStyles.body.copyWith(
                  color: fromMe ? Colors.white : AdminColors.primary,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminChatText {
  static final RegExp _markerPattern = RegExp(
    r'\[\[ACTION:([A-Z_]+):([^\]]+)\]\]',
  );

  static String clean(String content) {
    return content
        .replaceAll(_markerPattern, '')
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1')
        .replaceAll(RegExp(r'\[([^\]]+)\]\s*\([^\)]+\)'), r'$1')
        .replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*[-*]\s*', multiLine: true), '')
        .replaceAll(RegExp(r'https?:\/\/[^\s\)]+'), '')
        .replaceAll(RegExp(r'^\s*\([^\)]*\)\s*$', multiLine: true), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}
