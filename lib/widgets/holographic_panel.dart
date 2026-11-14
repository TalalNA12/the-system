import 'package:flutter/material.dart';

import 'system_window.dart';


class HolographicPanel extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? headerAction;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool isWarning;
  final Color? borderColor;
  final Color? glowColor;
  final bool showOuterRails;
  final bool showHeaderBox;
  final IconData? headerIcon;

  const HolographicPanel({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.headerAction,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
    this.isWarning = false,
    this.borderColor,
    this.glowColor,
    this.showOuterRails = true,
    this.showHeaderBox = true,
    this.headerIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SystemWindow(
      title: title,
      subtitle: subtitle,
      headerAction: headerAction,
      padding: padding,
      margin: margin,
      isWarning: isWarning,
      primaryColor: borderColor,
      showOuterRails: showOuterRails,
      showHeader: showHeaderBox,
      child: child,
    );
  }
}
