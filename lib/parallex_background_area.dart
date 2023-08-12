import 'package:flutter/material.dart';


class ParallaxBackgroundArea extends StatefulWidget {
  ParallaxBackgroundArea({Key? key, required this.child, this.scrollController})
      : super(key: key);

  final Widget child;

  final ScrollController? scrollController;

  @override
  _ParallaxBackgroundAreaState createState() => _ParallaxBackgroundAreaState();

   static ParallaxData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ParallaxData>();
  }
}

class _ParallaxBackgroundAreaState extends State<ParallaxBackgroundArea> {
  final List<Function(ScrollNotification?, RenderObject?)> _listeners = [];
  late VoidCallback scrollListener;

  @override
  void initState() {
    super.initState();
    scrollListener = () => _handleEvent();
    widget.scrollController?.addListener(scrollListener);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _handleEvent();
    });
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollEvent) {
        _handleEvent(scrollEvent);
        return false;
      },
      child: ParallaxData(
        listeners: _listeners,
        child: widget.child,
        onAdd: (listener) {
          final renderObject = context.findRenderObject();
          if (renderObject != null) {
            listener(null, renderObject);
          }
        },
        onUpdateRequest: () {
          _handleEvent();
        },
      ),
    );
  }

  void _handleEvent([ScrollNotification? event]) {
    if (_listeners.isNotEmpty) {
      RenderObject? renderObject = context.findRenderObject();
      _listeners.forEach((callback) {
        callback(null, renderObject);
      });
    }
  }
}




class ParallaxData extends InheritedWidget {
  final Widget child;
  final List<Function(ScrollNotification, RenderObject)> listeners;
  final Function(Function(ScrollNotification?, RenderObject)) onAdd;
  final VoidCallback? onUpdateRequest;

  ParallaxData(
      {Key? key,
        this.listeners = const [],
        required this.child,
        required this.onAdd,
        this.onUpdateRequest})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return (oldWidget as ParallaxData).listeners != listeners;
  }

  void addListener(
      Function(ScrollNotification? scrollEvent, RenderObject? renderObject)
      listener) {
    listeners.add(listener);
    onAdd.call(listener);
  }

  void requestUpdate() {
    onUpdateRequest?.call();
  }

  void removeListener(
      Function(ScrollNotification scrollEvent, RenderObject renderObject)
      listener) {
    listeners.remove(listener);
  }
}
