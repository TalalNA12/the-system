import 'package:flutter/material.dart';

import 'holographic_panel.dart';



class SystemPanel extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? headerAction;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool isWarning;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool showCornerNotches;

  const SystemPanel({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.headerAction,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
    this.isWarning = false,
    this.borderColor,
    this.backgroundColor,
    this.showCornerNotches = true,
  });

  @override
  Widget build(BuildContext context) {
    return HolographicPanel(
      title: title,
      subtitle: subtitle,
      headerAction: headerAction,
      padding: padding,
      margin: margin,
      isWarning: isWarning,
      borderColor: borderColor,
      showOuterRails: showCornerNotches,
      child: child,
    );
  }
}
