import 'package:JsxposedX/core/extensions/context_extensions.dart';
import 'package:JsxposedX/feature/ai/data/prompts/system_prompts.dart';
import 'package:JsxposedX/feature/ai/presentation/providers/chat/ai_chat_action_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AiQuickActions extends ConsumerWidget {
  final String packageName;
  final String? systemPrompt;
  final VoidCallback? onOpenAnalysis;

  const AiQuickActions({
    super.key,
    required this.packageName,
    this.systemPrompt,
    this.onOpenAnalysis,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isZh = context.isZh;

    void sendQuickAction(String prompt) {
      ref
          .read(aiChatActionProvider(packageName: packageName).notifier)
          .send(prompt);
    }

    return Container(
      height: 36.h,
      margin: EdgeInsets.only(top: 8.h, bottom: 4.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          if (onOpenAnalysis != null)
            _QuickActionTile(
              icon: Icons.inventory_2_outlined,
              label: context.l10n.aiReverseOpenAnalysis,
              color: Colors.blueGrey,
              onTap: onOpenAnalysis!,
            ),
          _QuickActionTile(
            icon: Icons.description_outlined,
            label: context.l10n.aiAnalyzeManifest,
            color: Colors.orange,
            onTap: () => sendQuickAction(
              SystemPrompts.quickAnalyzeManifest(isZh: isZh),
            ),
          ),
          _QuickActionTile(
            icon: Icons.security_outlined,
            label: context.l10n.aiHardeningDetection,
            color: Colors.green,
            onTap: () => sendQuickAction(
              SystemPrompts.quickHardeningDetection(isZh: isZh),
            ),
          ),
          _QuickActionTile(
            icon: Icons.code_outlined,
            label: context.l10n.aiExportInterfaces,
            color: Colors.blue,
            onTap: () => sendQuickAction(
              SystemPrompts.quickExportInterfaces(isZh: isZh),
            ),
          ),
          _QuickActionTile(
            icon: Icons.terminal_outlined,
            label: context.l10n.aiFindHookPoints,
            color: Colors.purple,
            onTap: () => sendQuickAction(
              SystemPrompts.quickFindHookPoints(isZh: isZh),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: context.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: color.withValues(alpha: 0.1), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16.sp),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: context.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
