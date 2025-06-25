import 'dart:math';

import 'package:flutter/material.dart';

class MultiSlidableListview extends StatefulWidget {
  const MultiSlidableListview({
    super.key,
    required this.children,
    this.controller,
    this.shrinkWrap = false,
    this.contentPadding,
    required this.rightSlideAction,
    required this.leftSlideAction,
    this.rightSlideIcon = const Icon(
      Icons.delete,
      color: Colors.white,
      size: 30,
    ),
    this.leftSlideIcon = const Icon(
      Icons.archive,
      color: Colors.white,
      size: 30,
    ),
    this.rightSlideColor = Colors.red,
    this.leftSlideColor = Colors.green,
    this.sliderBorderRadius,
  }) : itemCount = null,
       itemBuilder = null,
       separatorBuilder = null;

  MultiSlidableListview.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.shrinkWrap = false,
    this.contentPadding,
    required this.rightSlideAction,
    required this.leftSlideAction,
    this.rightSlideIcon = const Icon(
      Icons.delete,
      color: Colors.white,
      size: 30,
    ),
    this.leftSlideIcon = const Icon(
      Icons.archive,
      color: Colors.white,
      size: 30,
    ),
    this.rightSlideColor = Colors.red,
    this.leftSlideColor = Colors.green,
    this.sliderBorderRadius,
  }) : children = [],
       separatorBuilder = null;

  MultiSlidableListview.separated({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.separatorBuilder,
    this.controller,
    this.shrinkWrap = false,
    this.contentPadding,
    required this.rightSlideAction,
    required this.leftSlideAction,
    this.rightSlideIcon = const Icon(
      Icons.delete,
      color: Colors.white,
      size: 30,
    ),
    this.leftSlideIcon = const Icon(
      Icons.archive,
      color: Colors.white,
      size: 30,
    ),
    this.rightSlideColor = Colors.red,
    this.leftSlideColor = Colors.green,
    this.sliderBorderRadius,
  }) : children = [];

  final List<Widget> children;
  final int? itemCount;
  final Widget Function(BuildContext context, int index)? itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final ScrollController? controller;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? contentPadding;
  final void Function(List<int> slidedItemsIndices)? rightSlideAction;
  final void Function(List<int> slidedItemsIndices)? leftSlideAction;
  final Widget rightSlideIcon;
  final Widget leftSlideIcon;
  final Color rightSlideColor;
  final Color leftSlideColor;
  final double? sliderBorderRadius;

  @override
  State<MultiSlidableListview> createState() => _MultiSlidableListviewState();
}

class _MultiSlidableListviewState extends State<MultiSlidableListview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final ScrollController _scrollController;
  final List<GlobalKey> _itemKeys = [];
  int? _dragItemId;
  int? _dragOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _scrollController = widget.controller ?? ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemCount = widget.itemCount ?? widget.children.length;
      setState(() {
        _itemKeys.clear();
        _itemKeys.addAll(List.generate(itemCount, (_) => GlobalKey()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.itemCount ?? widget.children.length;

    final itemBuilder =
        widget.itemBuilder ??
        (BuildContext context, int index) => widget.children[index];

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => getActionBackground(),
        ),
        ListView.builder(
          controller: _scrollController,
          shrinkWrap: widget.shrinkWrap,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            bool isDraggable = false;
            if (_dragItemId != null && _dragOffset != null) {
              final top = min(_dragItemId!, _dragItemId! + _dragOffset!);
              final bottom = max(_dragItemId!, _dragItemId! + _dragOffset!);
              isDraggable = (index >= top && index <= bottom);
            }

            final item = Padding(
              key: _itemKeys.length > index ? _itemKeys[index] : null,
              padding: widget.contentPadding ?? EdgeInsets.zero,
              child: itemBuilder(context, index),
            );

            // final isRightSwipe = _controller.value > 0;

            return SlideTile(
              controller: _controller,
              isAffected: isDraggable,
              onDragStart: () => _dragItemId = index,
              onDragUpdate: (delta, posY, _) {
                _controller.value += delta;
                setState(() {
                  _dragOffset =
                      posY ~/
                      (_itemKeys[index].currentContext?.size?.height ?? 1);
                });
              },
              onDragEnd: animateDragEnd,
              child: isDraggable
                  ? Material(
                      // borderRadius: BorderRadius.horizontal(
                      //   left: isRightSwipe ? Radius.zero : Radius.circular(16),
                      //   right: isRightSwipe ? Radius.circular(16) : Radius.zero,
                      // ),
                      color: _controller.value < 0
                          ? widget.rightSlideColor
                          : _controller.value > 0
                          ? widget.leftSlideColor
                          : Colors.transparent,
                      child: item,
                    )
                  : item,
            );
          },
        ),
      ],
    );
  }

  Widget getActionBackground() {
    if (_dragItemId == null || _dragOffset == null) return SizedBox.shrink();

    final itemCount = widget.itemCount ?? widget.children.length;
    final start = _dragItemId!;
    final end = (_dragItemId! + _dragOffset!).clamp(0, itemCount - 1);
    final top = min(start, end);
    final bottom = max(start, end);

    double topOffset = 0;
    double totalHeight = 0;

    final topContext = _itemKeys[top].currentContext;
    if (topContext == null) return SizedBox.shrink();

    final listViewBox = context.findRenderObject() as RenderBox?;
    final itemBox = topContext.findRenderObject() as RenderBox?;

    if (listViewBox == null || itemBox == null) return SizedBox.shrink();

    final listTopY = listViewBox.localToGlobal(Offset.zero).dy;
    final itemTopY = itemBox.localToGlobal(Offset.zero).dy;

    topOffset = itemTopY - listTopY;

    for (int i = top; i <= bottom; i++) {
      final ctx = _itemKeys[i].currentContext;
      final box = ctx?.findRenderObject() as RenderBox?;
      totalHeight += box?.size.height ?? 0;
    }

    final isRightSwipe = _controller.value > 0;
    final width = _controller.value.abs();
    final color = isRightSwipe ? widget.leftSlideColor : widget.rightSlideColor;

    return Positioned(
      left: isRightSwipe ? 0 : null,
      right: isRightSwipe ? null : 0,
      top: topOffset,
      height: totalHeight,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.horizontal(
            left: isRightSwipe
                ? Radius.circular(widget.sliderBorderRadius ?? 0)
                : Radius.zero,
            right: isRightSwipe
                ? Radius.zero
                : Radius.circular(widget.sliderBorderRadius ?? 0),
          ),
        ),
        child: width >= 25
            ? Center(
                child: isRightSwipe
                    ? widget.leftSlideIcon
                    : widget.rightSlideIcon,
              )
            : null,
      ),
    );
  }

  void animateDragEnd() {
    double screenWidth = MediaQuery.of(context).size.width;
    if (_controller.value > screenWidth * 0.25) {
      _controller.animateTo(
        screenWidth,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_controller.value < -(screenWidth * 0.25)) {
      _controller.animateTo(
        -screenWidth,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _controller.animateBack(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _dragItemId != null) {
        final start = _dragItemId!;
        final offset = _dragOffset ?? 0;
        final top = min(start, start + offset);
        final bottom = max(start, start + offset);
        final affected = List.generate(bottom - top + 1, (i) => top + i);

        final isRightSwipe = _controller.value > 0;
        if (isRightSwipe) {
          widget.leftSlideAction?.call(affected);
        } else {
          widget.rightSlideAction?.call(affected);
        }

        _dragItemId = null;
        _dragOffset = null;
      }
      _controller.value = 0;
      setState(() {});
    });
  }
}

class SlideTile extends StatelessWidget {
  const SlideTile({
    super.key,
    required this.controller,
    required this.isAffected,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.child,
  });

  final AnimationController controller;
  final bool isAffected;
  final VoidCallback onDragStart;
  final void Function(double delta, double posY, double height) onDragUpdate;
  final VoidCallback onDragEnd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) => Transform.translate(
        offset: Offset(isAffected ? controller.value : 0, 0),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (_) => onDragStart(),
          onHorizontalDragUpdate: (details) {
            final height =
                (context.findRenderObject() as RenderBox?)?.size.height ?? 1;
            onDragUpdate(
              details.primaryDelta ?? 0,
              details.localPosition.dy,
              height,
            );
          },
          onHorizontalDragEnd: (_) => onDragEnd(),
          child: child,
        ),
      ),
    );
  }
}
