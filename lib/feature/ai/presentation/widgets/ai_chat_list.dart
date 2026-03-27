import 'package:JsxposedX/core/extensions/context_extensions.dart';
import 'package:JsxposedX/core/models/ai_message.dart';
import 'package:JsxposedX/feature/ai/presentation/providers/chat/ai_chat_action_provider.dart';
import 'package:JsxposedX/feature/ai/presentation/widgets/ai_chat_bubble/ai_chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AiChatList extends HookConsumerWidget {
  const AiChatList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.packageName,
    this.systemPrompt,
    this.customTitle,
    this.customSubtitle,
  });

  final List<AiMessage> messages;
  final ScrollController scrollController;
  final String packageName;
  final String? systemPrompt;
  final String? customTitle;
  final String? customSubtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (messages.isEmpty) {
      return Container(
        height: 0.5.sh,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  context.colorScheme.primary,
                  context.colorScheme.secondary,
                ],
              ).createShader(bounds),
              child: Icon(Icons.auto_awesome, size: 80.w, color: Colors.white),
            ),
            SizedBox(height: 24.h),
            Text(
              customTitle ?? context.l10n.aiAssistantTitle,
              style: TextStyle(
                color: context.textTheme.titleLarge?.color?.withValues(alpha: 0.8),
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              customSubtitle ?? context.l10n.aiAssistantSubtitle,
              style: TextStyle(
                color: context.theme.hintColor,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      );
    }

    final chatState = ref.watch(aiChatActionProvider(packageName: packageName));
    final chatNotifier = ref.read(aiChatActionProvider(packageName: packageName).notifier);
    final totalVisibleCount = chatState.totalVisibleMessagesCount;
    final hasMore = messages.length < totalVisibleCount;
    final remainingCount = (totalVisibleCount - messages.length).clamp(0, totalVisibleCount);
    final reversedMessages = messages.reversed.toList(growable: false);

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemCount: reversedMessages.length + (hasMore ? 1 : 0),
      cacheExtent: 500,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        if (index == reversedMessages.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: TextButton(
              onPressed: chatNotifier.loadMore,
              child: Text(
                context.l10n.aiShowMoreMessages(remainingCount),
                style: TextStyle(color: context.colorScheme.primary),
              ),
            ),
          );
        }

        final message = reversedMessages[index];
        final shouldShowStreaming =
            index == 0 &&
            chatState.isStreaming &&
            message.role == 'assistant' &&
            !message.isError;

        if (shouldShowStreaming) {
          return _StreamingAiChatBubble(
            key: ValueKey(message.id),
            role: message.role,
            isError: message.isError,
            isToolCalling: message.isToolResultBubble,
            streamingContentStream: chatNotifier.streamingContentStream,
            onRetry: () => chatNotifier.retryByMessageId(message.id),
            packageName: packageName,
          );
        }

        return RepaintBoundary(
          child: AiChatBubble(
            key: ValueKey(message.id),
            content: message.content,
            role: message.role,
            isError: message.isError,
            isToolCalling:
                message.isToolResultBubble &&
                !message.content.startsWith('✅') &&
                !message.content.startsWith('❌'),
            onRetry: () => chatNotifier.retryByMessageId(message.id),
            packageName: packageName,
          ),
        );
      },
    );
  }
}

class _StreamingAiChatBubble extends HookWidget {
  const _StreamingAiChatBubble({
    super.key,
    required this.role,
    required this.isError,
    required this.isToolCalling,
    required this.streamingContentStream,
    this.onRetry,
    this.packageName,
  });

  final String role;
  final bool isError;
  final bool isToolCalling;
  final Stream<String> streamingContentStream;
  final VoidCallback? onRetry;
  final String? packageName;

  @override
  Widget build(BuildContext context) {
    final content = useState('');
    final lastUpdateTime = useState<DateTime?>(null);

    useEffect(() {
      final subscription = streamingContentStream.listen((data) {
        if (!context.mounted) {
          return;
        }

        final now = DateTime.now();
        final lastUpdate = lastUpdateTime.value;
        if (data.isEmpty ||
            lastUpdate == null ||
            now.difference(lastUpdate).inMilliseconds >= 50) {
          lastUpdateTime.value = now;
          if (data != content.value) {
            content.value = data;
          }
        }
      });

      return subscription.cancel;
    }, [streamingContentStream]);

    return RepaintBoundary(
      child: AiChatBubble(
        content: content.value,
        role: role,
        isError: isError,
        isToolCalling: isToolCalling,
        onRetry: onRetry,
        packageName: packageName,
      ),
    );
  }
}
