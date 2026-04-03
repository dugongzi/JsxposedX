import 'package:JsxposedX/core/extensions/context_extensions.dart';
import 'package:JsxposedX/feature/ai/domain/models/padi_chat_options.dart';
import 'package:JsxposedX/feature/ai/presentation/providers/chat/ai_chat_action_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PadiChatOptionsBar extends HookConsumerWidget {
  const PadiChatOptionsBar({
    super.key,
    required this.packageName,
  });

  final String packageName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = useState(false);
    final chatState = ref.watch(aiChatActionProvider(packageName: packageName));
    final notifier = ref.read(
      aiChatActionProvider(packageName: packageName).notifier,
    );
    final supportedEfforts = PadiChatOptions.supportedEffortsForModel(
      chatState.currentPadiModel,
    );

    return Container(
      margin: EdgeInsets.only(top: 4.h, bottom: 6.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: context.isDark
              ? context.colorScheme.surfaceContainerLow
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => expanded.value = !expanded.value,
              borderRadius: BorderRadius.circular(10.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${context.l10n.aiBuiltinConfigName} · ${chatState.currentPadiModel} · ${_localizedEffort(context, chatState.currentPadiReasoningEffort)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      expanded.value
                          ? context.l10n.aiPadiOptionsCollapse
                          : context.l10n.aiPadiOptionsExpand,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: context.theme.hintColor,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      expanded.value
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 18.sp,
                      color: context.theme.hintColor,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded.value) ...[
              SizedBox(height: 8.h),
              _OptionsRow(
                title: context.l10n.aiPadiModelLabel,
                children: PadiChatOptions.models
                    .map(
                      (model) => _OptionChip(
                        label: model,
                        selected: chatState.currentPadiModel == model,
                        onTap: () => notifier.updatePadiChatOptions(model: model),
                      ),
                    )
                    .toList(growable: false),
              ),
              SizedBox(height: 6.h),
              _OptionsRow(
                title: context.l10n.aiPadiReasoningLabel,
                children: supportedEfforts
                    .map(
                      (effort) => _OptionChip(
                        label: _localizedEffort(context, effort),
                        selected: chatState.currentPadiReasoningEffort == effort,
                        onTap: () => notifier.updatePadiChatOptions(
                          reasoningEffort: effort,
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _localizedEffort(BuildContext context, String effort) {
    switch (effort) {
      case PadiChatOptions.effortNone:
        return context.l10n.aiPadiEffortNone;
      case PadiChatOptions.effortLow:
        return context.l10n.aiPadiEffortLow;
      case PadiChatOptions.effortMedium:
        return context.l10n.aiPadiEffortMedium;
      case PadiChatOptions.effortHigh:
        return context.l10n.aiPadiEffortHigh;
      case PadiChatOptions.effortXHigh:
        return context.l10n.aiPadiEffortXHigh;
      default:
        return effort;
    }
  }
}

class _OptionsRow extends StatelessWidget {
  const _OptionsRow({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.h,
      child: Row(
        children: [
          SizedBox(
            width: 60.w,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color: context.theme.hintColor,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: selected
                ? primary.withValues(alpha: 0.14)
                : (context.isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: selected
                  ? primary.withValues(alpha: 0.55)
                  : context.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? primary
                  : context.textTheme.bodyMedium?.color?.withValues(alpha: 0.82),
            ),
          ),
        ),
      ),
    );
  }
}
