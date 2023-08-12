import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inifinite_parallax/parallex_background_area.dart';

class ParallaxWidget extends StatefulWidget {
  const ParallaxWidget({
    Key? key,
    required this.child,
    this.background,
    this.overflowWidthFactor = 2,
    this.overflowHeightFactor = 2,
    this.fixedHorizontal = false,
    this.fixedVertical = false,
    this.inverted = false,
    this.alignment = Alignment.center,
    this.clipOverflow = true,
    this.showDebugInfo = false,
    this.parallaxPadding = EdgeInsets.zero,
  }) : super(key: key);


  final Widget child;

  final Widget? background;

  final double overflowWidthFactor;

  final double overflowHeightFactor;

  final bool fixedHorizontal;

  final bool fixedVertical;

  final bool inverted;

  final Alignment alignment;

  final bool clipOverflow;


  final EdgeInsets parallaxPadding;

  final bool showDebugInfo;

  @override
  _ParallaxWidgetState createState() => _ParallaxWidgetState();
}

class _ParallaxWidgetState extends State<ParallaxWidget> {
  ParallaxData? parallaxArea;
  late Function(ScrollNotification?, RenderObject?) parallaxListener;
  Offset _backgroundOffset = const Offset(0.5, 0.5);
  String _debugInfo = "No info";

  @override
  void initState() {
    super.initState();
    if (widget.overflowWidthFactor < 1 || widget.overflowHeightFactor < 1) {
      throw ArgumentError(
          "Overflows minimum value is 1, current overflow values(W: ${widget.overflowWidthFactor} - H: ${widget.overflowHeightFactor})");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      parallaxListener = _computeParallaxOffset;
      parallaxArea?.addListener(parallaxListener);
    });
  }

  @override
  void didChangeDependencies() {
    parallaxArea = ParallaxBackgroundArea.of(context);
    if (parallaxArea == null) {
      throw ArgumentError("No ParallaxArea found over this widget in the tree");
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
     parallaxArea?.removeListener(parallaxListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
            child: Padding(
              padding: widget.parallaxPadding,
              child: OptionalClipRect(
                clip: widget.clipOverflow,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    double maxWidth =
                        constraints.maxWidth * widget.overflowWidthFactor;
                    double maxHeight =
                        constraints.maxHeight * widget.overflowHeightFactor;
                    return OverflowBox(
                        alignment:
                        Alignment(_backgroundOffset.dx, _backgroundOffset.dy),
                        maxHeight: maxHeight,
                        maxWidth: maxWidth,
                        child: SizedBox.fromSize(
                          size: Size(maxWidth, maxHeight),
                          child: widget.background,
                        ));
                  },
                ),
              ),
            )),
        widget.child,
        if (widget.showDebugInfo)
          Positioned.fill(
            child: Container(
                alignment: Alignment.center,
                color: Colors.blue.withOpacity(0.8),
                child: Text(
                  _debugInfo,
                  style: const  TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
          ),
      ],
    );
  }

 void _computeParallaxOffset(ScrollNotification? scrollNotification,
      RenderObject? parallaxAreaRenderObject) {
    if (parallaxAreaRenderObject == null) {
      return;
    }

    final parallaxOffset = _getParallaxOffset(parallaxAreaRenderObject);

     if (parallaxOffset != null &&
        (parallaxOffset.dx != _backgroundOffset.dx ||
            parallaxOffset.dy != _backgroundOffset.dy)) {
      setState(() {
        _backgroundOffset = parallaxOffset;
      });
    }
  }

   Offset? _getParallaxOffset(RenderObject parallaxAreaRenderObject) {
     final renderObject = context.findRenderObject();

     if (renderObject == null || renderObject.attached != true) {
      return null;
    }

    final translation = renderObject.getTransformTo(null).getTranslation();
    final translationOffset = Offset(translation.x, translation.y);
    final shiftedRect = renderObject.paintBounds.shift(translationOffset);

    final areaTranslation =
    parallaxAreaRenderObject.getTransformTo(null).getTranslation();
    final areaTranslationOffset = Offset(areaTranslation.x, areaTranslation.y);
    final areaShiftedRect =
    parallaxAreaRenderObject.paintBounds.shift(areaTranslationOffset);

    double verticalOffsetRatio;
    double horizontalOffsetRatio;

    if (!shiftedRect.overlaps(areaShiftedRect)) {
      return null;
    }

    double centerVertical = shiftedRect.center.dy;
    double startingVerticalPoint =
        centerVertical + shiftedRect.height / 2 * widget.alignment.y;

    if (widget.fixedVertical) {
      verticalOffsetRatio = widget.alignment.y;
    } else {
      double shiftedY = startingVerticalPoint - areaShiftedRect.top;
      verticalOffsetRatio = shiftedY / areaShiftedRect.height;
      verticalOffsetRatio = verticalOffsetRatio * -2 + 1 + widget.alignment.y;
    }

    final centerHorizontal = shiftedRect.center.dx;
    final startingHorizontalPoint =
        centerHorizontal + shiftedRect.width / 2 * widget.alignment.x;

    if (widget.fixedHorizontal) {
      horizontalOffsetRatio = widget.alignment.x;
    } else {
      double shiftedX = startingHorizontalPoint - areaShiftedRect.left;
      horizontalOffsetRatio = shiftedX / areaShiftedRect.width;
      horizontalOffsetRatio =
          horizontalOffsetRatio * -2 + 1 + widget.alignment.x;
    }

    Offset finalOffset;

    if (widget.inverted) {
      verticalOffsetRatio *= -1;
      horizontalOffsetRatio *= -1;
    }

    finalOffset = Offset(
      max(min(1, horizontalOffsetRatio), -1),
      max(min(1, verticalOffsetRatio), -1),
    );


    _debugInfo = "Offset: $finalOffset"
        "\nAligmnent: ${widget.alignment}"
        "\nCenter vertical: $centerVertical"
        "\nshifted: ${shiftedRect.toString()}"
        "\nAreaShifted: ${areaShiftedRect.toString()}"
        "\nAligmnent: ${widget.alignment}";

    return finalOffset;
  }
}


class OptionalClipRect extends StatelessWidget {
  final Widget child;
  final bool clip;

  const OptionalClipRect({Key? key, required this.child, this.clip = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return clip ? ClipRect(child: child) : child;
  }
}
