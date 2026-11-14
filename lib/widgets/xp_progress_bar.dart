import 'package:flutter/material.dart';

import '../theme/app_theme.dart';


class XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int maxXp;
  final double height;
  final bool showLabels;
  final String label;
  final Color? barColor;

  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.maxXp,
    this.height = 6.0,
    this.showLabels = true,
    this.label = 'XP',
    this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final double fraction = maxXp > 0
        ? (currentXp / maxXp).clamp(0.0, 1.0)
        : 0.0;
    final Color activeColor = barColor ?? AppTheme.electricCyan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabels) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.sans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$currentXp / $maxXp',
                style: AppTheme.sans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: activeColor,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0x66020815),
            border: Border.all(
              color: activeColor.withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: fraction),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: activeColor,
                            boxShadow: [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.6),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
