import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/system_header.dart';
import '../widgets/system_window.dart';
import '../widgets/xp_progress_bar.dart';


class FitnessScreen extends StatelessWidget {
  const FitnessScreen({super.key});

  void _showNotice(BuildContext context, String action) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.hourglass_top,
              color: AppTheme.electricCyan,
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '[$action] Biometric logging unlocks in Milestone 2.',
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const SystemHeader(
              title: 'THE SYSTEM',
              subtitle: 'PHYSICAL CONDITIONING',
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
                    
                    _buildPhysicalStatus(context),

                    const SizedBox(height: 10),

                    
                    _buildTrainingRecord(context),

                    const SizedBox(height: 10),

                    
                    _buildNutritionStatus(context),

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

  Widget _buildPhysicalStatus(BuildContext context) {
    const int currentSteps = 6500;
    const int targetSteps = 10000;

    return SystemWindow(
      title: 'PHYSICAL STATUS',
      subtitle: '[Daily Locomotion Quota]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SystemGoalHeader(title: 'LOCOMOTION GOAL'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Current Steps',
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
                '[$currentSteps / $targetSteps]',
                style: AppTheme.sans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const XpProgressBar(
            currentXp: currentSteps,
            maxXp: targetSteps,
            label: 'QUOTA COMPLETION',
            height: 6.0,
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            label: 'SYNC LOCOMOTION LOG',
            onTap: () => _showNotice(context, 'SYNC STEPS'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingRecord(BuildContext context) {
    final exercises = [
      {
        'name': 'Barbell Back Squat',
        'load': '4 Sets x 6 Reps',
        'weight': '125 kg',
      },
      {
        'name': 'Romanian Deadlift',
        'load': '3 Sets x 8 Reps',
        'weight': '105 kg',
      },
      {
        'name': 'Bulgarian Split Squat',
        'load': '3 Sets x 10 Reps',
        'weight': '24 kg',
      },
      {
        'name': 'Hanging Leg Raise',
        'load': '3 Sets x 15 Reps',
        'weight': 'Bodyweight',
      },
    ];

    return SystemWindow(
      title: 'TRAINING RECORD',
      subtitle: '[Hypertrophy Regimen A]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SystemGoalHeader(title: 'ACTIVE REGIMEN'),
          const SizedBox(height: 10),
          ...exercises.map(
            (e) => Container(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 2.0,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.electricCyan.withValues(alpha: 0.08),
                    width: 0.8,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      e['name']!,
                      style: AppTheme.sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textWhite,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      '[${e['load']!}]',
                      textAlign: TextAlign.center,
                      style: AppTheme.sans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.softBlue,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '[${e['weight']!}]',
                      textAlign: TextAlign.right,
                      style: AppTheme.sans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            label: 'RECORD TRAINING SESSION',
            onTap: () => _showNotice(context, 'RECORD WORKOUT'),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionStatus(BuildContext context) {
    const int consumed = 1950;
    const int target = 2600;

    return SystemWindow(
      title: 'NUTRITION STATUS',
      subtitle: '[Metabolic Fuel Allocation]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SystemGoalHeader(title: 'CALORIC INTAKE'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Calories Consumed',
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
                '[$consumed / $target kcal]',
                style: AppTheme.sans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const XpProgressBar(
            currentXp: consumed,
            maxXp: target,
            label: 'CALORIE QUOTA',
            height: 6.0,
          ),
          const SizedBox(height: 10),
          _buildMacroRow('Protein', '145 / 180 g'),
          _buildMacroRow('Carbohydrates', '210 / 280 g'),
          _buildMacroRow('Lipids / Fats', '58 / 75 g'),
          const SizedBox(height: 10),
          _buildActionButton(
            label: 'LOG NUTRITIONAL INTAKE',
            onTap: () => _showNotice(context, 'LOG NUTRITION'),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.sans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '[$value]',
            style: AppTheme.sans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.softBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x33040E20),
        border: Border.all(
          color: AppTheme.electricCyan.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: AppTheme.electricCyan.withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7.0),
            child: Center(
              child: Text(
                label,
                style: AppTheme.sans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppTheme.electricCyan,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
