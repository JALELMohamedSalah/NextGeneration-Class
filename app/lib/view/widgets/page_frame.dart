import 'package:flutter/material.dart';

import '../../core/network/api_failure.dart';
import '../../core/theme/brand_colors.dart';
import '../stateManager/common/load_status.dart';
import 'feedback.dart';

/// Whether the screen uses the phone layout (header and bottom bar).
bool isPhone(BuildContext context) => MediaQuery.sizeOf(context).width < Breakpoints.tablet;

/// The scrolling page of a shell screen: page padding (32, phone 18), content at most [maxWidth] wide,
/// aligned to the start.
class PageScroll extends StatelessWidget {
  const PageScroll({super.key, required this.children, this.maxWidth = Breakpoints.contentMaxWidth, this.gap = 24});

  final List<Widget> children;
  final double maxWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(phone ? 18 : 32),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: phone ? 16 : gap),
                FadeRise(index: i, child: children[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Width of the pupil's and parent's pages: the same frame as the teacher's, so a computer screen is used.
/// Their lists go in [CardColumns]; phones keep one column.
const familyPageWidth = Breakpoints.contentMaxWidth;

/// Cards in columns when there is room: as many columns of at least [minColumnWidth] as fit, at most
/// [maxColumns], filled row by row (the first two cards side by side, then the next two). One column below.
/// Uses a [LayoutBuilder]: never inside an equal-height [PairedBlocks].
class CardColumns extends StatelessWidget {
  const CardColumns({super.key, required this.children, this.minColumnWidth = 380, this.maxColumns = 2, this.gap = 12});

  final List<Widget> children;
  final double minColumnWidth;
  final int maxColumns;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ((constraints.maxWidth + gap) ~/ (minColumnWidth + gap)).clamp(1, maxColumns);
        Widget column(List<Widget> items) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[if (i > 0) SizedBox(height: gap), items[i]],
          ],
        );
        if (columns == 1) return column(children);
        final lists = List.generate(columns, (_) => <Widget>[]);
        for (var i = 0; i < children.length; i++) {
          lists[i % columns].add(children[i]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var c = 0; c < columns; c++) ...[if (c > 0) SizedBox(width: gap), Expanded(child: column(lists[c]))],
          ],
        );
      },
    );
  }
}

/// Two blocks side by side (flex 7 and 5) when the content is wide enough, one under the other otherwise.
class PairedBlocks extends StatelessWidget {
  const PairedBlocks({super.key, required this.start, required this.end, this.startFlex = 7, this.endFlex = 5, this.equalHeight = true});

  final Widget start;
  final Widget end;
  final int startFlex;
  final int endFlex;

  /// Stretch both blocks to the taller one (cards side by side). Off for columns of cards.
  final bool equalHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < Breakpoints.pairedBlocks) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              start,
              SizedBox(height: isPhone(context) ? 16 : 24),
              end,
            ],
          );
        }
        final row = Row(
          crossAxisAlignment: equalHeight ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
          children: [
            Expanded(flex: startFlex, child: start),
            const SizedBox(width: 24),
            Expanded(flex: endFlex, child: end),
          ],
        );
        return equalHeight ? IntrinsicHeight(child: row) : row;
      },
    );
  }
}

/// Cards fade in and rise 12 px, one after the other (40 ms apart). Nothing moves when the system
/// asks for fewer animations.
class FadeRise extends StatefulWidget {
  const FadeRise({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  State<FadeRise> createState() => _FadeRiseState();
}

class _FadeRiseState extends State<FadeRise> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 300 + 40 * widget.index.clamp(0, 8)),
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Interval(40 * widget.index.clamp(0, 8) / (300 + 40 * widget.index.clamp(0, 8)), 1, curve: Curves.easeOut),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.isDismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) => Opacity(
        opacity: _progress.value,
        child: Transform.translate(offset: Offset(0, 12 * (1 - _progress.value)), child: child),
      ),
      child: widget.child,
    );
  }
}

/// Loading, failure or content, cross-faded. While data already shown is refreshed, it stays
/// with a thin progress line on top; a first load shows only the line (no skeleton, UI spec 4).
class AsyncView extends StatelessWidget {
  const AsyncView({super.key, required this.status, required this.hasData, required this.builder, required this.onRetry, this.failure});

  final LoadStatus status;
  final bool hasData;
  final ApiFailure? failure;
  final VoidCallback onRetry;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final Widget body;
    final String key;
    if (hasData) {
      key = 'data';
      body = Stack(
        children: [
          Positioned.fill(child: builder(context)),
          if (status == LoadStatus.loading) const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: 3)),
        ],
      );
    } else if (status == LoadStatus.failure && failure != null) {
      key = 'failure';
      body = PageScroll(children: [FailureBanner(failure!, onRetry: onRetry)]);
    } else {
      key = 'loading';
      body = const Align(alignment: Alignment.topCenter, child: LinearProgressIndicator(minHeight: 3));
    }
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 220),
      child: KeyedSubtree(key: ValueKey(key), child: body),
    );
  }
}
