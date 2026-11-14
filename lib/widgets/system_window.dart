import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SystemWindow extends StatefulWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? headerAction;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool isWarning;
  final Color? primaryColor;
  final bool showOuterRails;
  final bool showHeader;

  const SystemWindow({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.headerAction,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
    this.isWarning = false,
    this.primaryColor,
    this.showOuterRails = true,
    this.showHeader = true,
  });

  @override
  State<SystemWindow> createState() => _SystemWindowState();
}

class _SystemWindowState extends State<SystemWindow>
    with TickerProviderStateMixin {
  late final AnimationController _energy;
  late final AnimationController _opening;

  @override
  void initState() {
    super.initState();

    
    _energy = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4700),
    )..repeat();

    
    _opening = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 840),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final reduced = MediaQuery.disableAnimationsOf(context);

    if (reduced) {
      _energy.stop();
      _opening.value = 1;
    } else {
      if (!_energy.isAnimating) _energy.repeat();
    }
  }

  @override
  void dispose() {
    _energy.dispose();
    _opening.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);

    final color =
        widget.primaryColor ??
        (widget.isWarning ? AppTheme.warningRed : AppTheme.softBlue);

    final panel = Container(
      margin: widget.margin,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: SystemWindowPainter(
            color: color,
            isWarning: widget.isWarning,
            showOuterRails: widget.showOuterRails,
            animation: _energy,
            animateBorder: !reduced,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              widget.showOuterRails ? 20 : 13,
              17,
              widget.showOuterRails ? 20 : 13,
              17,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.showHeader && widget.title != null) ...[
                  _buildHeader(color, reduced),
                  const SizedBox(height: 12),
                ],
                Padding(padding: widget.padding, child: widget.child),
              ],
            ),
          ),
        ),
      ),
    );

    if (reduced) return panel;

    
    
    return AnimatedBuilder(
      animation: _opening,
      child: panel,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_opening.value);

        return Opacity(
          opacity: (t * 1.7).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 17),
            child: Transform.scale(
              alignment: Alignment.topCenter,
              scaleX: 0.985 + t * 0.015,
              scaleY: 0.90 + t * 0.10,
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Color color, bool reduced) {
    Widget titleBox(double glow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xC9091C33),
          border: Border.all(
            color: color.withValues(alpha: 0.55 + glow * 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: glow * 0.40),
              blurRadius: 7 + glow * 15,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.9)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: glow * 0.3),
                    blurRadius: 7,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '!',
                  style: TextStyle(
                    color: color,
                    height: 1,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                widget.title!.toUpperCase(),
                textAlign: TextAlign.center,
                style:
                    AppTheme.sans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textWhite,
                      letterSpacing: 2,
                    ).copyWith(
                      shadows: [
                        Shadow(
                          color: color.withValues(alpha: 0.35 + glow * 0.60),
                          blurRadius: 7 + glow * 14,
                        ),
                      ],
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (reduced)
          titleBox(0.5)
        else
          AnimatedBuilder(
            animation: Listenable.merge([_energy, _opening]),
            builder: (context, child) {
              final t = _energy.value * math.pi * 2;
              final pulse = 0.5 + 0.5 * math.sin(t);
              final arrival = Curves.easeOut.transform(_opening.value);
              return titleBox((pulse * 0.35 + arrival * 0.65).clamp(0.0, 1.0));
            },
          ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.subtitle!.startsWith('[')
                ? widget.subtitle!
                : '[${widget.subtitle}]',
            textAlign: TextAlign.center,
            style: AppTheme.sans(
              color: AppTheme.softBlue,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
        if (widget.headerAction != null) ...[
          const SizedBox(height: 8),
          widget.headerAction!,
        ],
      ],
    );
  }
}

class SystemWindowPainter extends CustomPainter {
  final Color color;
  final bool isWarning;
  final bool showOuterRails;
  final Animation<double>? animation;
  final bool animateBorder;

  SystemWindowPainter({
    required this.color,
    this.isWarning = false,
    this.showOuterRails = true,
    this.animation,
    this.animateBorder = true,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(
      showOuterRails ? 11 : 2,
      5,
      size.width - (showOuterRails ? 11 : 2),
      size.height - 5,
    );

    final phase = animateBorder ? (animation?.value ?? 0) * math.pi * 2 : 0.0;

    
    
    final flicker = animateBorder
        ? (0.62 +
                  0.14 * math.sin(phase) +
                  0.10 * math.sin(phase * 3.7) +
                  0.06 * math.sin(phase * 7.1))
              .clamp(0.35, 0.95)
        : 0.68;

    _drawGlass(canvas, rect);
    _drawDepth(canvas, rect);
    _drawFrame(canvas, rect, flicker);
    _drawCorners(canvas, rect, phase, flicker);

    if (showOuterRails) {
      _drawRails(canvas, rect, flicker);
    }
  }

  void _drawGlass(Canvas canvas, Rect rect) {
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isWarning
            ? [
                const Color(0xF024091A),
                const Color(0xF00D0510),
                const Color(0xF0080309),
              ]
            : [
                const Color(0xF00B2542),
                const Color(0xF006142D),
                const Color(0xF0020918),
              ],
        stops: const [0, 0.48, 1],
      ).createShader(rect);

    canvas.drawRect(rect, background);

    
    canvas.drawRect(
      Rect.fromLTRB(rect.left + 2, rect.top + 2, rect.right - 2, rect.top + 19),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.08), Colors.transparent],
        ).createShader(rect),
    );

    
    final line = Paint()
      ..color = color.withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final path = Path()
      ..moveTo(rect.left + rect.width * 0.18, rect.top)
      ..lineTo(rect.left + rect.width * 0.40, rect.top + rect.height * 0.35)
      ..lineTo(rect.left + rect.width * 0.30, rect.top + rect.height * 0.65)
      ..moveTo(rect.right - rect.width * 0.13, rect.top)
      ..lineTo(rect.right - rect.width * 0.38, rect.top + rect.height * 0.55);

    canvas.drawPath(path, line);
  }

  void _drawDepth(Canvas canvas, Rect rect) {
    
    canvas.drawRect(
      rect.inflate(1.5),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    
    
    canvas.drawLine(
      rect.topLeft + const Offset(2, 2),
      rect.topRight + const Offset(-2, 2),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..strokeWidth = 1,
    );

    canvas.drawLine(
      rect.topLeft + const Offset(2, 2),
      rect.bottomLeft + const Offset(2, -2),
      Paint()
        ..color = color.withValues(alpha: 0.30)
        ..strokeWidth = 1.4,
    );

    canvas.drawLine(
      rect.bottomLeft + const Offset(2, -2),
      rect.bottomRight + const Offset(-2, -2),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.70)
        ..strokeWidth = 2,
    );

    canvas.drawLine(
      rect.topRight + const Offset(-2, 2),
      rect.bottomRight + const Offset(-2, -2),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.50)
        ..strokeWidth = 2,
    );
  }

  void _drawFrame(Canvas canvas, Rect rect, double flicker) {
    
    canvas.drawRect(
      rect,
      Paint()
        ..color = color.withValues(alpha: flicker * 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );

    
    canvas.drawRect(
      rect,
      Paint()
        ..color = color.withValues(alpha: 0.48 + flicker * 0.37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    
    canvas.drawRect(
      rect.deflate(4),
      Paint()
        ..color = color.withValues(alpha: 0.17 + flicker * 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    
    canvas.drawLine(
      rect.topLeft + const Offset(5, 1),
      rect.topRight + const Offset(-5, 1),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12 + flicker * 0.22)
        ..strokeWidth = 0.7,
    );
  }

  void _drawCorners(Canvas canvas, Rect rect, double phase, double flicker) {
    const length = 16.0;

    final points = [
      (rect.topLeft, 1.0, 1.0),
      (rect.topRight, -1.0, 1.0),
      (rect.bottomLeft, 1.0, -1.0),
      (rect.bottomRight, -1.0, -1.0),
    ];

    for (var i = 0; i < points.length; i++) {
      final (point, dx, dy) = points[i];

      
      final spark = (0.60 + 0.40 * math.sin(phase * 2 + i * 1.7)).clamp(
        0.0,
        1.0,
      );

      final p = Path()
        ..moveTo(point.dx, point.dy + dy * length)
        ..lineTo(point.dx, point.dy)
        ..lineTo(point.dx + dx * length, point.dy);

      canvas.drawPath(
        p,
        Paint()
          ..color = color.withValues(alpha: flicker * spark * 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      canvas.drawPath(
        p,
        Paint()
          ..color = Color.lerp(
            color,
            Colors.white,
            0.55,
          )!.withValues(alpha: 0.65 + spark * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.7,
      );

      
      final insetPoint = Offset(point.dx + dx * 5, point.dy + dy * 5);

      canvas.drawLine(
        insetPoint,
        Offset(insetPoint.dx + dx * 7, insetPoint.dy),
        Paint()
          ..color = color.withValues(alpha: 0.48)
          ..strokeWidth = 0.9,
      );
    }
  }

  void _drawRails(Canvas canvas, Rect rect, double flicker) {
    final y = rect.center.dy;

    final left = Path()
      ..moveTo(rect.left - 5, rect.top + 14)
      ..lineTo(rect.left - 5, y - 36)
      ..lineTo(rect.left - 8, y - 30)
      ..lineTo(rect.left - 8, y - 12)
      ..lineTo(rect.left - 6, y - 12)
      ..lineTo(rect.left - 6, y + 12)
      ..lineTo(rect.left - 8, y + 12)
      ..lineTo(rect.left - 8, y + 30)
      ..lineTo(rect.left - 5, y + 36)
      ..lineTo(rect.left - 5, rect.bottom - 14);

    final right = Path()
      ..moveTo(rect.right + 5, rect.top + 14)
      ..lineTo(rect.right + 5, y - 36)
      ..lineTo(rect.right + 8, y - 30)
      ..lineTo(rect.right + 8, y - 12)
      ..lineTo(rect.right + 6, y - 12)
      ..lineTo(rect.right + 6, y + 12)
      ..lineTo(rect.right + 8, y + 12)
      ..lineTo(rect.right + 8, y + 30)
      ..lineTo(rect.right + 5, y + 36)
      ..lineTo(rect.right + 5, rect.bottom - 14);

    for (final path in [left, right]) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: flicker * 0.35)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.55 + flicker * 0.3)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SystemWindowPainter old) {
    return old.color != color ||
        old.isWarning != isWarning ||
        old.showOuterRails != showOuterRails ||
        old.animateBorder != animateBorder ||
        old.animation != animation;
  }
}

class SystemGoalHeader extends StatelessWidget {
  final String title;
  final Color? color;

  const SystemGoalHeader({super.key, this.title = 'GOAL', this.color});

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppTheme.softBlue;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTheme.sans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.textWhite,
              letterSpacing: 2.2,
              glow: true,
            ),
          ),
          const SizedBox(height: 4),
          Container(height: 1, width: 40, color: activeColor),
          const SizedBox(height: 2),
          Container(
            height: 1,
            width: 28,
            color: activeColor.withValues(alpha: 0.55),
          ),
        ],
      ),
    );
  }
}
