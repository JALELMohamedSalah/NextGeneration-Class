import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/brand_colors.dart';
import '../../l10n/app_localizations.dart';
import '../stateManager/document/document_cubit.dart';
import 'cards.dart';
import 'page_frame.dart';

/// The current page of the [DocumentCubit] above, zoomable, with the page bar (the viewer and the correction screen).
class DocumentPages extends StatefulWidget {
  const DocumentPages({super.key, this.compact = false});

  /// A narrow pane (the correction screen on a phone): small margins, the page bar without zoom.
  final bool compact;

  @override
  State<DocumentPages> createState() => _DocumentPagesState();
}

class _DocumentPagesState extends State<DocumentPages> {
  final _zoom = TransformationController();

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  void _scale(double factor) {
    final current = _zoom.value.getMaxScaleOnAxis();
    final next = (current * factor).clamp(1.0, 4.0);
    setState(() => _zoom.value = Matrix4.identity()..scaleByDouble(next, next, 1, 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context) || widget.compact;
    final state = context.watch<DocumentCubit>().state;
    final cubit = context.read<DocumentCubit>();
    final url = state.view!.pageUrls[state.page];
    final percent = (_zoom.value.getMaxScaleOnAxis() * 100).round();

    final pageBar = Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: BrandColors.ink, borderRadius: BorderRadius.circular(14), boxShadow: AppShadows.menu),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BarButton(icon: LucideIcons.chevronLeftDir, tooltip: l10n.previousPage, onPressed: state.page > 0 ? cubit.previous : null),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(l10n.pageOf(state.page + 1, state.pageCount), style: text.style(13, FontWeight.w700, color: Colors.white)),
          ),
          _BarButton(
            icon: LucideIcons.chevronRightDir,
            tooltip: l10n.nextPage,
            onPressed: state.page < state.pageCount - 1 ? cubit.next : null,
          ),
          if (!phone) ...[
            Container(width: 1, height: 20, margin: const EdgeInsets.symmetric(horizontal: 6), color: Colors.white24),
            _BarButton(icon: LucideIcons.zoomOut, tooltip: l10n.zoomOut, onPressed: () => _scale(1 / 1.25)),
            Text(
              '$percent %',
              textDirection: TextDirection.ltr,
              style: text.style(13, FontWeight.w700, color: Colors.white),
            ),
            _BarButton(icon: LucideIcons.zoomIn, tooltip: l10n.zoomIn, onPressed: () => _scale(1.25)),
          ],
        ],
      ),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: _zoom,
            minScale: 1,
            maxScale: 4,
            onInteractionEnd: (_) => setState(() {}),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(phone ? 8 : 28, phone ? 12 : 28, phone ? 8 : 28, phone ? 12 : 84),
              child: Center(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Color(0x1F1C2566), blurRadius: 30, offset: Offset(0, 8))],
                  ),
                  child: Image.network(
                    url,
                    key: ValueKey(url),
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : const SizedBox(width: 320, height: 420, child: Center(child: CircularProgressIndicator(strokeWidth: 2.5))),
                    errorBuilder: (context, _, _) => SizedBox(
                      width: 320,
                      height: 260,
                      child: Center(
                        child: ErrorBanner(message: l10n.pageNotShown, onRetry: cubit.load),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!phone) PositionedDirectional(start: 0, end: 0, bottom: 20, child: Center(child: pageBar)),
      ],
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    color: Colors.white,
    disabledColor: Colors.white38,
    visualDensity: VisualDensity.compact,
  );
}
