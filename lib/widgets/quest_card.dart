import 'package:flutter/material.dart';

import '../models/player.dart';
import '../theme/app_theme.dart';




class QuestRow extends StatelessWidget {
  final Quest quest;
  final VoidCallback? onTap;
  final bool showDivider;

  const QuestRow({
    super.key,
    required this.quest,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = quest.isCompleted || quest.progressFraction >= 1.0;

    return InkWell(
      onTap: onTap,
      splashColor: AppTheme.electricCyan.withValues(alpha: 0.15),
      highlightColor: Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
            child: Row(
              children: [
                
                Expanded(
                  child: Text(
                    quest.title,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.sans(
                      fontSize: 13,
                      fontWeight: isCompleted
                          ? FontWeight.w500
                          : FontWeight.w600,
                      color: isCompleted
                          ? AppTheme.textWhite.withValues(alpha: 0.85)
                          : AppTheme.textWhite,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                
                Text(
                  '[${quest.currentProgress}/${quest.targetProgress}]',
                  style: AppTheme.sans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? AppTheme.softBlue : AppTheme.textWhite,
                    letterSpacing: 0.6,
                  ),
                ),

                const SizedBox(width: 10),

                
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successGreen.withValues(alpha: 0.15)
                        : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? AppTheme.successGreen
                          : AppTheme.iceBlue.withValues(alpha: 0.6),
                      width: 1.0,
                    ),
                    boxShadow: isCompleted
                        ? [
                            BoxShadow(
                              color: AppTheme.successGreen.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 11,
                            color: AppTheme.successGreen,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Container(
              height: 0.8,
              color: AppTheme.electricCyan.withValues(alpha: 0.08),
            ),
        ],
      ),
    );
  }
}


class QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback? onTap;

  const QuestCard({super.key, required this.quest, this.onTap});

  @override
  Widget build(BuildContext context) {
    return QuestRow(quest: quest, onTap: onTap);
  }
}
