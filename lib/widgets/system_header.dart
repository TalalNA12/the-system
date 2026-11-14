import 'package:flutter/material.dart';

import '../theme/app_theme.dart';



class SystemHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const SystemHeader({
    super.key,
    this.title = 'THE SYSTEM',
    this.subtitle = 'PLAYER STATUS',
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
      child: Center(
        child: Text(
          title.toUpperCase(),
          style: AppTheme.sans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.0,
            color: AppTheme.textMuted.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}
