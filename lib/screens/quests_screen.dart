import 'package:flutter/material.dart';

import '../models/player.dart';
import '../theme/app_theme.dart';
import '../widgets/quest_card.dart';
import '../widgets/system_header.dart';
import '../widgets/system_window.dart';


class QuestsScreen extends StatelessWidget {
  const QuestsScreen({super.key});

  void _showMilestoneNotice(BuildContext context, String action) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.auto_awesome,
              color: AppTheme.electricCyan,
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '[$action] Quest customization will unlock in Milestone 2.',
                style: AppTheme.sans(
                  color: AppTheme.textWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const systemQuests = Quest.demoSystemQuests;
    const personalQuests = Quest.demoPersonalQuests;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const SystemHeader(
              title: 'THE SYSTEM',
              subtitle: 'QUEST DIRECTIVES',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 2.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    SystemWindow(
                      title: 'QUEST INFO',
                      subtitle: '[Active Quest Objectives]',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SystemGoalHeader(title: 'MANDATORY GOALS'),
                          const SizedBox(height: 8),
                          ...systemQuests.map(
                            (quest) => QuestRow(
                              quest: quest,
                              onTap: () =>
                                  _showMilestoneNotice(context, quest.title),
                            ),
                          ),

                          const SizedBox(height: 14),

                          const SystemGoalHeader(title: 'PERSONAL GOALS'),
                          const SizedBox(height: 8),
                          ...personalQuests.map(
                            (quest) => QuestRow(
                              quest: quest,
                              onTap: () =>
                                  _showMilestoneNotice(context, quest.title),
                            ),
                          ),

                          const SizedBox(height: 14),

                          
                          _buildAddQuestButton(context),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    
                    _buildQuestRewardsWindow(context),

                    const SizedBox(height: 10),

                    
                    _buildPenaltySurvivalWindow(),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddQuestButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x33040E20),
        border: Border.all(
          color: AppTheme.electricCyan.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMilestoneNotice(context, 'ADD QUEST'),
          splashColor: AppTheme.electricCyan.withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: AppTheme.electricCyan, size: 14),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '+ INITIALIZE PERSONAL QUEST',
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.sans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppTheme.electricCyan,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestRewardsWindow(BuildContext context) {
    final rewards = [
      '1. Full Recovery',
      '2. Ability Points +3',
      '3. Random Loot BOX',
    ];

    return SystemWindow(
      title: 'QUEST REWARDS',
      subtitle: '[Daily Quest Rewards]',
      child: Column(
        children: [
          Text(
            'You got rewards.',
            style: AppTheme.sans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          ...rewards.map(
            (reward) => Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 3.0),
              padding: const EdgeInsets.symmetric(
                vertical: 7.0,
                horizontal: 14.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0x22040E20),
                border: Border.all(
                  color: AppTheme.electricCyan.withValues(alpha: 0.35),
                  width: 0.8,
                ),
              ),
              child: Text(
                reward,
                style: AppTheme.sans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Accept these rewards?',
            style: AppTheme.sans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRewardButton(
                'YES',
                () => _showMilestoneNotice(context, 'ACCEPT REWARDS'),
              ),
              const SizedBox(width: 12),
              _buildRewardButton(
                'No',
                () => _showMilestoneNotice(context, 'DECLINE REWARDS'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardButton(String label, VoidCallback onTap) {
    return Container(
      width: 75,
      decoration: BoxDecoration(
        color: const Color(0x33040E20),
        border: Border.all(
          color: AppTheme.electricCyan.withValues(alpha: 0.45),
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Center(
              child: Text(
                label,
                style: AppTheme.sans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textWhite,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPenaltySurvivalWindow() {
    return SystemWindow(
      isWarning: true,
      title: 'QUEST INFO',
      subtitle: '[Penalty Quest: Survival]',
      child: Column(
        children: [
          const SystemGoalHeader(title: 'GOAL', color: AppTheme.warningRed),
          const SizedBox(height: 6),
          Text(
            'Survive',
            style: AppTheme.sans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textWhite,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: AppTheme.sans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textWhite,
                letterSpacing: 1.2,
              ),
              children: [
                const TextSpan(text: '03:59:54'),
                TextSpan(
                  text: ' / 4h',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
