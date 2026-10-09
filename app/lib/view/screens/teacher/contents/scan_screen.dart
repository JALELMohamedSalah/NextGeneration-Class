import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/l10n/tunis_time.dart';
import '../../../../core/platform/photo_source.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/content.dart';
import '../../../../domain/model/scan.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/scan/scan_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/panels.dart';
import 'crop_screen.dart';

/// "Scanner des feuilles" (design `r2/Scanner.png`, screen 2): photos one after another, put in order,
/// cropped, then one PDF made on the device. Returns that PDF, or null when abandoned.
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  static Future<PickedFile?> open(BuildContext context) => Navigator.of(context).push<PickedFile>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => BlocProvider(create: (_) => ScanCubit(sl.get(), sl.get()), child: const ScanScreen()),
    ),
  );

  /// Black and white as the PDF will be: grey, a little more contrast.
  static const blackWhite = ColorFilter.matrix([
    0.30, 1.00, 0.10, 0, -51, //
    0.30, 1.00, 0.10, 0, -51,
    0.30, 1.00, 0.10, 0, -51,
    0, 0, 0, 1, 0,
  ]);

  Future<void> _close(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    if (context.read<ScanCubit>().state.pages.isNotEmpty) {
      final ok = await confirmAction(
        context,
        title: l10n.scanDiscardTitle,
        text: l10n.scanDiscardText,
        confirmLabel: l10n.scanDiscard,
        icon: LucideIcons.trash2,
      );
      if (!ok) return;
    }
    navigator.pop();
  }

  Future<void> _create(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final language = context.read<LanguageCubit>().state;
    final navigator = Navigator.of(context);
    final today = TunisTime.wall(sl.get<Now>()());
    final file = await context.read<ScanCubit>().build('${l10n.scanFileName(dayMonth(today, language))}.pdf');
    if (file != null) navigator.pop(file);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<ScanCubit>().state;
    final cubit = context.read<ScanCubit>();
    final camera = sl.get<PhotoSource>().hasCamera;

    final header = Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: BrandColors.line)),
      ),
      child: Row(
        children: [
          IconSquareButton(icon: LucideIcons.x, tooltip: l10n.cancel, onPressed: () => _close(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.scanSheets, style: text.style(18, FontWeight.w800)),
                Text(l10n.pagesCount(state.pages.length), style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
              ],
            ),
          ),
        ],
      ),
    );

    final Widget content;
    if (state.pages.isEmpty && !state.adding) {
      content = _Empty(camera: camera, onAdd: camera ? cubit.takePhoto : cubit.pickPhotos);
    } else {
      content = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedChoice<ScanColor>(
                    value: state.color,
                    onChanged: cubit.setColor,
                    options: [SelectOption(ScanColor.color, l10n.scanColor), SelectOption(ScanColor.blackWhite, l10n.scanBlackWhite)],
                  ),
                  const SizedBox(height: 14),
                  _PageGrid(camera: camera),
                  const SizedBox(height: 14),
                  InfoNote(text: l10n.scanHint),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final problem = switch (state.problem) {
      ScanProblem.photo => l10n.scanPhotoFailed,
      ScanProblem.pdf => l10n.scanPdfFailed,
      null => null,
    };
    final busy = state.adding || state.building;
    final bottom = Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BrandColors.line)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (problem != null) ...[
                Text(
                  problem,
                  textAlign: TextAlign.center,
                  style: text.style(13, FontWeight.w600, color: Accent.red.onSoft),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  if (camera) ...[
                    Expanded(
                      child: TonalButton(
                        label: l10n.takePhoto,
                        icon: LucideIcons.camera,
                        height: 50,
                        onPressed: busy ? null : cubit.takePhoto,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: _OutlineButton(
                      label: camera ? l10n.fromGallery : l10n.addPhotos,
                      icon: LucideIcons.images,
                      onPressed: busy ? null : cubit.pickPhotos,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: l10n.createPdf,
                icon: LucideIcons.fileText,
                height: 52,
                loading: state.building,
                onPressed: state.pages.isEmpty || state.adding ? null : () => _create(context),
              ),
            ],
          ),
        ),
      ),
    );

    return PopScope(
      canPop: state.pages.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close(context);
      },
      child: Scaffold(
        backgroundColor: BrandColors.chalk,
        body: SafeArea(
          child: Column(
            children: [
              header,
              Expanded(child: content),
              bottom,
            ],
          ),
        ),
      ),
    );
  }
}

/// No page yet. On a computer there is no camera: the teacher adds photos already taken.
class _Empty extends StatelessWidget {
  const _Empty({required this.camera, required this.onAdd});

  final bool camera;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Accent.turquoise.soft,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onAdd,
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: Icon(camera ? LucideIcons.camera : LucideIcons.images, size: 40, color: BrandColors.turquoiseDeep),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                camera ? l10n.scanEmptyTitle : l10n.scanEmptyTitleComputer,
                textAlign: TextAlign.center,
                style: text.style(18, FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                camera ? l10n.scanEmptyHint : l10n.scanEmptyHintComputer,
                textAlign: TextAlign.center,
                style: text.style(14, FontWeight.w500, color: BrandColors.body, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The pages in order, two or more per row; hold a page to move it, tap it to crop it.
class _PageGrid extends StatelessWidget {
  const _PageGrid({required this.camera});

  final bool camera;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<ScanCubit>().state;
    final cubit = context.read<ScanCubit>();
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final columns = (constraints.maxWidth / 190).floor().clamp(2, 5);
        final width = ((constraints.maxWidth - gap * (columns - 1)) / columns).floorToDouble();
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (i, page) in state.pages.indexed)
              SizedBox(
                width: width,
                child: DragTarget<String>(
                  onWillAcceptWithDetails: (details) => details.data != page.id,
                  onAcceptWithDetails: (details) => cubit.move(details.data, i),
                  builder: (context, candidates, _) => LongPressDraggable<String>(
                    data: page.id,
                    feedback: Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: width,
                        child: _PageTile(page: page, number: i + 1, lifted: true),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _PageTile(page: page, number: i + 1),
                    ),
                    child: _PageTile(page: page, number: i + 1, target: candidates.isNotEmpty),
                  ),
                ),
              ),
            if (state.adding)
              SizedBox(
                width: width,
                height: 196,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: BrandColors.line),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.5)),
                      const SizedBox(height: 10),
                      Text(l10n.scanPreparing, style: text.style(13, FontWeight.w600, color: BrandColors.slate)),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                width: width,
                height: 196,
                child: Material(
                  color: const Color(0xFFF4F5FC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF9AA3D9), width: 1.5),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: camera ? cubit.takePhoto : cubit.pickPhotos,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(camera ? LucideIcons.camera : LucideIcons.images, size: 26, color: BrandColors.indigo),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            camera ? l10n.takePhoto : l10n.addPhotos,
                            textAlign: TextAlign.center,
                            style: text.style(13, FontWeight.w700, color: BrandColors.indigo),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PageTile extends StatelessWidget {
  const _PageTile({required this.page, required this.number, this.lifted = false, this.target = false});

  final ScanPage page;
  final int number;
  final bool lifted;

  /// Another page is held over this one: it will take its place.
  final bool target;

  Future<void> _crop(BuildContext context) async {
    final cubit = context.read<ScanCubit>();
    final pages = cubit.state.pages;
    final result = await Navigator.of(context).push(CropScreen.route(page, pages.indexOf(page), pages.length));
    if (result == null) return;
    final edited = result.page;
    if (edited == null) return cubit.remove(page.id);
    await cubit.updatePage(edited);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final blackWhite = context.select((ScanCubit c) => c.state.color == ScanColor.blackWhite);
    Widget image = Image.memory(page.preview, fit: BoxFit.contain, gaplessPlayback: true);
    if (blackWhite) image = ColorFiltered(colorFilter: ScanScreen.blackWhite, child: image);
    return Semantics(
      label: l10n.pageNumber(number),
      button: true,
      child: Material(
        color: Colors.white,
        elevation: lifted ? 8 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: target ? BrandColors.indigo : BrandColors.line, width: target ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: lifted ? null : () => _crop(context),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(height: 150, color: const Color(0xFFE9EBF3), alignment: Alignment.center, child: image),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: BrandColors.ink, shape: BoxShape.circle),
                          // The tile already says "Page 2" to screen readers.
                          child: ExcludeSemantics(
                            child: Text('$number', style: text.style(12, FontWeight.w800, color: Colors.white)),
                          ),
                        ),
                        const Spacer(),
                        const Icon(LucideIcons.gripVertical, size: 18, color: BrandColors.slate),
                      ],
                    ),
                  ],
                ),
              ),
              if (!lifted)
                PositionedDirectional(
                  top: 12,
                  end: 12,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: IconButton(
                      tooltip: l10n.deletePage,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
                      padding: EdgeInsets.zero,
                      onPressed: () => context.read<ScanCubit>().remove(page.id),
                      icon: Icon(LucideIcons.x, size: 16, color: Accent.red.onSoft),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// White with a line: the second choice beside a tonal button.
class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.icon, required this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final color = onPressed == null ? BrandColors.slate : BrandColors.ink;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        side: const BorderSide(color: BrandColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: onPressed,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.style(14, FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
