import 'package:flutter/material.dart';

/// 数据类定义菜单项
class ActionItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool enabled;
  final Color? color;

  const ActionItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.enabled = true,
    this.color,
  });
}

/// 底部升起的操作菜单组件
class BottomActionSheet {
  static void show(
    BuildContext context, {
    required List<ActionItem> actions,
    String? title,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7, // 大屏不全屏
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部拖拽条
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Divider(color: colorScheme.outline.withOpacity(0.2)),
            ],
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: action.enabled ? () {
                        Navigator.of(context).pop();
                        action.onTap();
                      } : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Icon(
                              action.icon,
                              color: action.enabled
                                  ? (action.color ?? colorScheme.onSurface)
                                  : colorScheme.onSurface.withOpacity(0.4),
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                action.title,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: action.enabled
                                      ? (action.color ?? colorScheme.onSurface)
                                      : colorScheme.onSurface.withOpacity(0.4),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (!action.enabled)
                              Icon(
                                Icons.block,
                                color: colorScheme.onSurface.withOpacity(0.4),
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

