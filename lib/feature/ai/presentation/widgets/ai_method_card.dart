import 'package:JsxposedX/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 方法签名卡片
///
/// 解析 ```method``` 块，每行一个方法，字段用 | 分隔：
/// name: method | return: boolean | modifier: public | params: (String id) | hook: isVip
class AiMethodCard extends StatelessWidget {
  final String rawContent;

  const AiMethodCard({super.key, required this.rawContent});

  static List<_MethodItem> _parse(String raw) {
    return raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).map((
      line,
    ) {
      final fields = <String, String>{};
      for (final part in line.split('|')) {
        final idx = part.indexOf(':');
        if (idx > 0) {
          fields[part.substring(0, idx).trim()] = part
              .substring(idx + 1)
              .trim();
        }
      }
      return _MethodItem(
        name: fields['name'] ?? fields['method'] ?? line,
        returnType: fields['return'] ?? fields['ret'],
        modifier: fields['modifier'] ?? fields['mod'],
        params: fields['params'] ?? fields['args'],
        hookHint: fields['hook'] ?? fields['hint'],
        className: fields['class'] ?? fields['cls'],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _parse(rawContent);
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < items.length; i++)
          _MethodTile(item: items[i], isLast: i == items.length - 1),
      ],
    );
  }
}

class _MethodItem {
  final String name;
  final String? returnType;
  final String? modifier;
  final String? params;
  final String? hookHint;
  final String? className;

  const _MethodItem({
    required this.name,
    this.returnType,
    this.modifier,
    this.params,
    this.hookHint,
    this.className,
  });
}

class _MethodTile extends StatelessWidget {
  final _MethodItem item;
  final bool isLast;

  const _MethodTile({required this.item, required this.isLast});

  static Color _modifierColor(String? mod, BuildContext ctx) {
    switch (mod?.toLowerCase()) {
      case 'public':
        return const Color(0xFF4CAF50);
      case 'private':
        return const Color(0xFFF44336);
      case 'protected':
        return const Color(0xFFFF9800);
      default:
        return ctx.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    final isDark = context.isDark;
    final modColor = _modifierColor(item.modifier, context);

    final signature =
        '${item.returnType != null ? '${item.returnType} ' : ''}${item.name}${item.params ?? '()'}'
            .trim();

    return GestureDetector(
      onTap: () => _showDetail(context),
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: signature));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已复制签名', style: TextStyle(fontSize: 13.sp)),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 6.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1F2E) : const Color(0xFFF5F7FF),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: primary.withValues(alpha: 0.18),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (item.modifier != null) ...[
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: modColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        item.modifier!,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: modColor,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
                if (item.returnType != null) ...[
                  Flexible(
                    child: Text(
                      item.returnType!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF2196F3),
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
                Expanded(
                  child: Text(
                    '${item.name}${item.params ?? '()'}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'monospace',
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.9)
                          : context.textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (item.className != null) ...[
              SizedBox(height: 3.h),
              Text(
                item.className!,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: context.theme.hintColor,
                  fontFamily: 'monospace',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (item.hookHint != null) ...[
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(Icons.link, size: 11.sp, color: primary),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      item.hookHint!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: primary.withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final primary = context.colorScheme.primary;
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.theme.dividerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              l10n.aiMethodDetail,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(
              context,
              l10n.aiMethodName,
              item.name,
              isCode: true,
            ),
            if (item.modifier != null)
              _buildDetailRow(
                context,
                l10n.aiMethodModifier,
                item.modifier!,
                isCode: true,
              ),
            if (item.returnType != null)
              _buildDetailRow(
                context,
                l10n.aiMethodReturnType,
                item.returnType!,
                isCode: true,
              ),
            if (item.params != null)
              _buildDetailRow(
                context,
                l10n.aiMethodParams,
                item.params!,
                isCode: true,
              ),
            if (item.className != null)
              _buildDetailRow(
                context,
                l10n.aiMethodClass,
                item.className!,
                isCode: true,
              ),
            if (item.hookHint != null)
              _buildDetailRow(context, l10n.aiMethodHookHint, item.hookHint!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isCode = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: context.theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: isCode ? 'monospace' : null,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
