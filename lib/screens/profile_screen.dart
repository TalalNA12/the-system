import 'package:flutter/material.dart';

import '../models/player.dart';
import '../theme/app_theme.dart';
import '../widgets/system_header.dart';
import '../widgets/system_window.dart';
import '../widgets/xp_progress_bar.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const player = Player.demoPlayer;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const SystemHeader(title: 'THE SYSTEM', subtitle: 'PLAYER STATUS'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 2.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    _buildPlayerStatusWindow(player),

                    const SizedBox(height: 10),

                    
                    _buildAttributesWindow(player),

                    const SizedBox(height: 10),

                    
                    _buildLockedTitlesWindow(),

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

  Widget _buildPlayerStatusWindow(Player player) {
    return SystemWindow(
      title: 'PLAYER STATUS',
      subtitle: '[Hunter Identification: ${player.name}]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SystemGoalHeader(title: 'PLAYER PARAMETERS'),
          const SizedBox(height: 10),
          _buildParamRow('Player Name', player.name),
          _buildParamRow('Level', player.formattedLevel),
          _buildParamRow('Rank', player.rank),
          _buildParamRow('Total Experience', '${player.totalXp} XP'),
          _buildParamRow('Quests Completed', '${player.questsCompleted}'),
          _buildParamRow('Active Streak', '${player.streakDays} Days'),
          const SizedBox(height: 10),
          XpProgressBar(
            currentXp: player.hp,
            maxXp: player.maxHp,
            label: 'HP',
            height: 6.0,
            barColor: AppTheme.warningRed,
          ),
          const SizedBox(height: 8),
          XpProgressBar(
            currentXp: player.currentXp,
            maxXp: player.maxXp,
            label: 'EXPERIENCE',
            height: 6.0,
            barColor: AppTheme.electricCyan,
          ),
        ],
      ),
    );
  }

  Widget _buildParamRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.sans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '[$value]',
            style: AppTheme.sans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributesWindow(Player player) {
    return SystemWindow(
      title: 'ATTRIBUTES',
      subtitle: '[Base Ability Ratings]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SystemGoalHeader(title: 'ABILITY RATINGS'),
          const SizedBox(height: 10),
          ...player.attributes.map((attr) {
            final fraction = (attr.value / attr.maxValue).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${attr.code} — ${attr.name}',
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.sans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textWhite,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '[${attr.value}]',
                        style: AppTheme.sans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.electricCyan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0x55020815),
                      border: Border.all(
                        color: AppTheme.electricCyan.withValues(alpha: 0.25),
                        width: 0.6,
                      ),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: fraction,
                      child: Container(color: AppTheme.electricCyan),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLockedTitlesWindow() {
    return SystemWindow(
      title: 'LOCKED TITLES',
      subtitle: '[Mythological Trials & Ascensions]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SystemGoalHeader(title: 'MYTHOLOGICAL TRIALS'),
          const SizedBox(height: 8),
          Text(
            'Titles and Mythological Trials will unlock in future updates.',
            textAlign: TextAlign.center,
            style: AppTheme.sans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildLockedBadge('OLYMPIAN VIGOR'),
              const SizedBox(width: 8),
              _buildLockedBadge('TITAN RECKONING'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLockedBadge(String title) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0x22040E20),
          border: Border.all(
            color: AppTheme.electricCyan.withValues(alpha: 0.25),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 11, color: AppTheme.textMuted),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.sans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
