import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/brand_colors.dart';

/// The four geometric characters of the brand (login board values at scale 1). Decorative only,
/// and never mirrored in Arabic.
class Classmates extends StatelessWidget {
  const Classmates({super.key, this.scale = 1});

  final double scale;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * scale;
    return ExcludeSemantics(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Body(
              width: s(96),
              height: s(200),
              color: BrandColors.indigo,
              top: s(48),
              child: Padding(
                padding: EdgeInsets.only(top: s(44)),
                child: _Eyes(
                  gap: s(10),
                  eye: _RingEye(size: s(18), pupil: s(8)),
                ),
              ),
            ),
            SizedBox(width: s(12)),
            _Body(
              width: s(200),
              height: s(100),
              color: BrandColors.turquoise,
              top: s(100),
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: s(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Eyes(
                      gap: s(30),
                      eye: _Dot(size: s(10), color: BrandColors.ink),
                    ),
                    SizedBox(height: s(8)),
                    CustomPaint(size: Size(s(30), s(13)), painter: _SmilePainter(s(4))),
                  ],
                ),
              ),
            ),
            SizedBox(width: s(12)),
            _Body(
              width: s(104),
              height: s(150),
              color: BrandColors.amber,
              top: s(32),
              child: Padding(
                padding: EdgeInsets.only(top: s(36)),
                child: _Eyes(
                  gap: s(18),
                  eye: _Dot(size: s(10), color: BrandColors.ink),
                ),
              ),
            ),
            SizedBox(width: s(12)),
            _Body(
              width: s(84),
              height: s(170),
              color: BrandColors.violet,
              top: s(42),
              child: Padding(
                padding: EdgeInsets.only(top: s(40)),
                child: _Eyes(
                  gap: s(10),
                  eye: _Dot(size: s(15), color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.width,
    required this.height,
    required this.color,
    required this.top,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  final double width;
  final double height;
  final Color color;
  final double top;
  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    alignment: alignment,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.vertical(top: Radius.circular(top)),
    ),
    child: child,
  );
}

class _SmilePainter extends CustomPainter {
  _SmilePainter(this.stroke);

  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = stroke / 2;
    final rect = Rect.fromLTRB(inset, -size.height + inset, size.width - inset, size.height - inset);
    canvas.drawArc(
      rect,
      0,
      math.pi,
      false,
      Paint()
        ..color = BrandColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_SmilePainter oldDelegate) => oldDelegate.stroke != stroke;
}

class _Eyes extends StatelessWidget {
  const _Eyes({required this.gap, required this.eye});

  final double gap;
  final Widget eye;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      eye,
      SizedBox(width: gap),
      eye,
    ],
  );
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _RingEye extends StatelessWidget {
  const _RingEye({required this.size, required this.pupil});

  final double size;
  final double pupil;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    child: _Dot(size: pupil, color: BrandColors.ink),
  );
}

/// What a block shows when it has nothing yet: the characters, one sentence, maybe one action.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.scale = 0.4, this.action});

  final String message;
  final double scale;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Classmates(scale: scale),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: text.style(14, FontWeight.w600, color: BrandColors.body, height: 1.5),
          ),
          if (action != null) ...[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}
