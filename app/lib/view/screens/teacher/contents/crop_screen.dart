import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/scan.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/scan/crop_cubit.dart';

/// What the crop screen gives back: the edited page, or null [page] when the page is deleted.
typedef CropResult = ({ScanPage? page});

/// One page (design `r2/Scanner.png`, screen 3): the four corners on the sheet's edges, a quarter turn,
/// back to the photo as taken.
class CropScreen extends StatelessWidget {
  const CropScreen({super.key, required this.index, required this.count});

  final int index;
  final int count;

  static const background = Color(0xFF14172E);

  static Route<CropResult> route(ScanPage page, int index, int count) => MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => BlocProvider(
      create: (_) => CropCubit(page),
      child: CropScreen(index: index, count: count),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final page = context.watch<CropCubit>().state;
    final cubit = context.read<CropCubit>();
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _DarkButton(icon: LucideIcons.arrowLeftDir, tooltip: l10n.back, onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l10n.pageOf(index + 1, count), style: text.style(17, FontWeight.w800, color: Colors.white)),
                  ),
                  _DarkButton(
                    icon: LucideIcons.trash2,
                    tooltip: l10n.deletePage,
                    color: const Color(0xFFFF8787),
                    onPressed: () => Navigator.of(context).pop<CropResult>((page: null)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // The handles stick out of the photo by half their size: the area keeps that margin, so a
                    // finger on a corner at the photo's edge still reaches it (touches only land inside a box).
                    const margin = 22.0;
                    final aspect = page.turnedAspect;
                    var width = constraints.maxWidth - 2 * margin;
                    var height = width / aspect;
                    if (height > constraints.maxHeight - 2 * margin) {
                      height = constraints.maxHeight - 2 * margin;
                      width = height * aspect;
                    }
                    return Center(
                      child: SizedBox(
                        width: width + 2 * margin,
                        height: height + 2 * margin,
                        // Points on a photo are left to right, whatever the language.
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Stack(
                            children: [
                              Positioned(
                                left: margin,
                                top: margin,
                                width: width,
                                height: height,
                                child: RotatedBox(
                                  quarterTurns: page.quarterTurns,
                                  child: Image.memory(page.bytes, fit: BoxFit.fill, gaplessPlayback: true),
                                ),
                              ),
                              Positioned(
                                left: margin,
                                top: margin,
                                width: width,
                                height: height,
                                child: CustomPaint(painter: _CropPainter(page.corners)),
                              ),
                              for (var i = 0; i < 4; i++)
                                Positioned(
                                  left: page.corners[i].x * width,
                                  top: page.corners[i].y * height,
                                  child: Semantics(
                                    label: l10n.cropCorner,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onPanUpdate: (details) {
                                        final c = context.read<CropCubit>().state.corners[i];
                                        cubit.moveCorner(i, ScanPoint(c.x + details.delta.dx / width, c.y + details.delta.dy / height));
                                      },
                                      child: SizedBox(
                                        width: 2 * margin,
                                        height: 2 * margin,
                                        child: Center(
                                          child: Container(
                                            width: 26,
                                            height: 26,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: BrandColors.indigo, width: 3),
                                              boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2))],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                l10n.cropHint,
                textAlign: TextAlign.center,
                style: text.style(13, FontWeight.w500, color: const Color(0xFFC9CCE0)),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 20),
              child: Row(
                children: [
                  _Tool(icon: LucideIcons.rotateCw, label: l10n.rotate, onPressed: cubit.rotate),
                  _Tool(icon: LucideIcons.undo2, label: l10n.resetCrop, onPressed: page.edited ? cubit.reset : null),
                  _Tool(
                    icon: LucideIcons.check,
                    label: l10n.validate,
                    primary: true,
                    onPressed: () => Navigator.of(context).pop<CropResult>((page: context.read<CropCubit>().state)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dims the photo outside the sheet and outlines it.
class _CropPainter extends CustomPainter {
  _CropPainter(this.corners);

  final List<ScanPoint> corners;

  @override
  void paint(Canvas canvas, Size size) {
    final points = [for (final c in corners) Offset(c.x * size.width, c.y * size.height)];
    final sheet = Path()..addPolygon(points, true);
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size)
        ..addPath(sheet, Offset.zero),
      Paint()..color = const Color(0x8C0A0C1E),
    );
    canvas.drawPath(
      sheet,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_CropPainter old) => old.corners != corners;
}

class _DarkButton extends StatelessWidget {
  const _DarkButton({required this.icon, required this.tooltip, required this.onPressed, this.color = Colors.white});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onPressed,
        child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 20, color: color)),
      ),
    ),
  );
}

class _Tool extends StatelessWidget {
  const _Tool({required this.icon, required this.label, required this.onPressed, this.primary = false});

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final enabled = onPressed != null;
    // The icon and its label are one tap target.
    return Expanded(
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Semantics(
          button: true,
          enabled: enabled,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadii.row),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: primary ? BrandColors.amber : Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.row),
                    ),
                    child: Icon(icon, size: 24, color: primary ? BrandColors.ink : Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.style(12, FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
