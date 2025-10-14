import 'package:flutter/material.dart';

import '../enums/page_view_mode.dart';
import '../flip/flip_settings.dart';
import '../model/paper_boundary_decoration.dart';
import 'page_turn_controller.dart';
import 'interactive_book_view.dart';

class InteractiveBook extends StatelessWidget {
  final PageTurnController? controller;
  final InteractiveBookBuilder builder;
  final int pageCount;
  final InteractiveBookCallback? onPageChanged;
  final FlipSettings settings;
  final PageViewMode pageViewMode;
  final bool autoResponseSize;
  final PaperBoundaryDecoration paperBoundaryDecoration;
  final double? aspectRatio;
  final bool pagesBoundaryIsEnabled;

  InteractiveBook({
    super.key,
    this.controller,
    this.aspectRatio,
    required this.builder,
    required this.pageCount,
    this.onPageChanged,
    this.pageViewMode = PageViewMode.single,
    this.autoResponseSize = true,
    this.paperBoundaryDecoration = PaperBoundaryDecoration.vintage,
    FlipSettings? settings,
    this.pagesBoundaryIsEnabled = true,
  }) : settings = settings ?? FlipSettings() {
    if (settings != null) {
      assert(
        this.settings.startPageIndex >= 0,
        'Page count must be greater than 0',
      );
      assert(
        this.settings.startPageIndex < pageCount,
        'Start page index must be less than page count',
      );
    }
  }

  Size _calculateBookSize({
    required double maxWidth,
    required double maxHeight,
    required double aspectRatio,
  }) {
    double height = maxWidth / aspectRatio;
    if (height > maxHeight) {
      height = maxHeight;
      maxWidth = height * aspectRatio;
    }
    return Size(maxWidth, height);
  }

  double _getAspectRatio(bool isMobile) {
    if (!autoResponseSize && pageViewMode == PageViewMode.single) {
      return aspectRatio ?? 2 / 3;
    }
    if (pageViewMode == PageViewMode.single) {
      return aspectRatio ?? 2 / 3 * (isMobile ? 1 : 2);
    }
    return aspectRatio ?? (2 / 3) * 2;
  }

  FlipSettings _getAdjustedSetting(bool isMobile) {
    if (!autoResponseSize && pageViewMode == PageViewMode.single) {
      return settings.copyWith(usePortrait: true);
    }
    final usePortrait = pageViewMode == PageViewMode.single && isMobile;
    return settings.copyWith(usePortrait: usePortrait);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final aspectRatio = _getAspectRatio(isMobile);
        FlipSettings adjustedSettings = _getAdjustedSetting(isMobile);

        final bookSize = _calculateBookSize(
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
          aspectRatio: aspectRatio,
        );
        adjustedSettings = adjustedSettings.copyWith(
          width: bookSize.width,
          height: bookSize.height,
        );

        return InteractiveBookView(
          builder: (context, index) => builder(context, index, constraints),
          bookSize: bookSize,
          settings: adjustedSettings,
          pageCount: pageCount,
          controller: controller,
          aspectRatio: aspectRatio,
          onPageChanged: onPageChanged,
          pagesBoundaryIsEnabled: pagesBoundaryIsEnabled,
          paperBoundaryDecoration: paperBoundaryDecoration,
        );
      },
    );
  }
}

typedef InteractiveBookBuilder =
    Widget Function(
      BuildContext context,
      int pageIndex,
      BoxConstraints constraints,
    );
typedef InteractiveBookCallback =
    void Function(int leftPageIndex, int rightPageIndex);
typedef PageWidgetBuilder = Widget Function(BuildContext context, int index);
