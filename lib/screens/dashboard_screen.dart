import 'dart:async';

import 'package:flutter/material.dart';

import '../models/player.dart';
import '../services/system_audio.dart';
import '../theme/app_theme.dart';
import '../widgets/quest_card.dart';
import '../widgets/system_header.dart';
import '../widgets/system_window.dart';
import '../widgets/xp_progress_bar.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToQuests;

  const DashboardScreen({super.key, this.onNavigateToQuests});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showSoundTests = false;

  void _playSound(SystemEffect effect) {
    unawaited(SystemAudio.instance.play(effect));
  }

  void _toggleMute() {
    final currentlyEnabled = SystemAudio.instance.enabled;

    setState(() {
      SystemAudio.instance.setMuted(currentlyEnabled);
    });
  }

  void _showQuestDetails(BuildContext context, Quest quest) {
    
    _playSound(SystemEffect.open);

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 14),
          child: SingleChildScrollView(
            child: SystemWindow(
              title: 'QUEST INFO',
              subtitle: 'System objective identified',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SystemGoalHeader(title: 'OBJECTIVE'),

                  const SizedBox(height: 20),

                  Text(
                    quest.title,
                    textAlign: TextAlign.center,
                    style: AppTheme.sans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textWhite,
                      letterSpacing: 0.7,
                      glow: true,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Complete this objective to progress '
                    'through the System.',
                    textAlign: TextAlign.center,
                    style: AppTheme.sans(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),

                  const SizedBox(height: 20),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.softBlue,
                      side: const BorderSide(color: AppTheme.softBlue),
                    ),
                    child: const Text('CLOSE'),
                  ),

                  if (widget.onNavigateToQuests != null) ...[
                    const SizedBox(height: 8),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        widget.onNavigateToQuests?.call();
                      },
                      child: const Text('OPEN QUEST LOG'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const player = Player.demoPlayer;
    const quests = Quest.demoSystemQuests;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const SystemHeader(title: 'THE SYSTEM', subtitle: 'PLAYER STATUS'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatusWindow(player),

                    const SizedBox(height: 10),

                    _buildQuestInfoWindow(context, quests),

                    const SizedBox(height: 18),

                    _buildAudioTestToggle(),

                    if (_showSoundTests) ...[
                      const SizedBox(height: 10),
                      _buildSoundTestPanel(),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWindow(Player player) {
    return SystemWindow(
      title: 'STATUS',
      subtitle: '[Player status interface active]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SystemGoalHeader(title: 'PLAYER STATUS'),

          const SizedBox(height: 12),

          _buildParamRow('Name', player.name),
          _buildParamRow('Level', player.formattedLevel),
          _buildParamRow('Rank', player.rank),

          const SizedBox(height: 10),

          XpProgressBar(
            currentXp: player.hp,
            maxXp: player.maxHp,
            label: 'HP',
            height: 6,
            barColor: AppTheme.warningRed,
          ),

          const SizedBox(height: 8),

          XpProgressBar(
            currentXp: player.currentXp,
            maxXp: player.maxXp,
            label: 'XP',
            height: 6,
            barColor: AppTheme.electricCyan,
          ),
        ],
      ),
    );
  }

  Widget _buildParamRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.sans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Text(
            '[$value]',
            style: AppTheme.sans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textWhite,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestInfoWindow(BuildContext context, List<Quest> quests) {
    return SystemWindow(
      title: 'QUEST INFO',
      subtitle: '[Daily Quest: Strength Training has arrived.]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SystemGoalHeader(title: 'GOAL'),

          const SizedBox(height: 12),

          ...quests.map(
            (quest) => QuestRow(
              quest: quest,
              onTap: () {
                _showQuestDetails(context, quest);
              },
            ),
          ),

          const SizedBox(height: 16),

          _buildAnimeWarning(),
        ],
      ),
    );
  }

  Widget _buildAnimeWarning() {
    return Text.rich(
      TextSpan(
        style: AppTheme.sans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppTheme.textMuted,
          letterSpacing: 0.4,
          height: 1.4,
        ),
        children: const [
          TextSpan(
            text: 'WARNING: ',
            style: TextStyle(
              color: AppTheme.warningRed,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text:
                'Failure to complete the daily quest will result '
                'in an appropriate ',
          ),
          TextSpan(
            text: 'penalty.',
            style: TextStyle(
              color: AppTheme.warningRed,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(color: AppTheme.warningRed, blurRadius: 6)],
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAudioTestToggle() {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          _playSound(SystemEffect.open);

          setState(() {
            _showSoundTests = !_showSoundTests;
          });
        },
        icon: Icon(
          _showSoundTests ? Icons.expand_less : Icons.graphic_eq,
          color: AppTheme.softBlue,
        ),
        label: Text(
          _showSoundTests ? 'HIDE AUDIO TEST' : 'OPEN AUDIO TEST',
          style: AppTheme.sans(
            color: AppTheme.softBlue,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildSoundTestPanel() {
    return SystemWindow(
      title: 'AUDIO TEST',
      subtitle: 'Temporary developer controls',
      child: Column(
        children: [
          const SystemGoalHeader(title: 'SYSTEM SOUNDS'),

          const SizedBox(height: 14),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _soundButton('SYSTEM OPEN', SystemEffect.open),
              _soundButton('QUEST COMPLETE', SystemEffect.questComplete),
              _soundButton('LEVEL UP', SystemEffect.levelUp),
              _soundButton('PENALTY', SystemEffect.penalty),
            ],
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: _toggleMute,
            icon: Icon(
              SystemAudio.instance.enabled ? Icons.volume_up : Icons.volume_off,
            ),
            label: Text(
              SystemAudio.instance.enabled ? 'MUTE SOUND' : 'UNMUTE SOUND',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.softBlue,
              side: const BorderSide(color: AppTheme.softBlue),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'DEVELOPER TEST MODE — NO XP IS AWARDED',
            textAlign: TextAlign.center,
            style: AppTheme.sans(fontSize: 10, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _soundButton(String title, SystemEffect effect) {
    return OutlinedButton(
      onPressed: () {
        _playSound(effect);
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textWhite,
        side: const BorderSide(color: AppTheme.softBlue, width: 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      child: Text(
        title,
        style: AppTheme.sans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppTheme.textWhite,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}
