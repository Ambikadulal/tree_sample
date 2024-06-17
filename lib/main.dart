// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Hierarchical Nodes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HierarchicalView(),
    );
  }
}

class HierarchicalView extends StatefulWidget {
  const HierarchicalView({super.key});

  @override
  _HierarchicalViewState createState() => _HierarchicalViewState();
}

class _HierarchicalViewState extends State<HierarchicalView> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _normalizedOffset = Offset.zero;

  final GlobalKey _parentKey = GlobalKey();
  final Map<GlobalKey, Offset> _nodePositions = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hierarchical Nodes'),
      ),
      body: GestureDetector(
        onScaleStart: (ScaleStartDetails details) {
          _previousScale = _scale;
          _normalizedOffset = (_offset - details.focalPoint) / _scale;
          setState(() {});
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          _scale = _previousScale * details.scale;
          _offset = details.focalPoint + _normalizedOffset * _scale;
          setState(() {});
        },
        onScaleEnd: (ScaleEndDetails details) {
          _previousScale = 1.0;
        },
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.blue.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Transform(
              transform: Matrix4.identity()
                ..translate(_offset.dx, _offset.dy)
                ..scale(_scale),
              child: CustomPaint(
                painter: NodePainter(nodePositions: _nodePositions),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Node(
                      key: _parentKey,
                      label: 'Parent Node',
                      nodePositions: _nodePositions,
                      children: [
                        Node(
                          label: 'Child 1',
                          nodePositions: _nodePositions,
                          children: [
                            Node(
                              label: 'Child 1.1',
                              nodePositions: _nodePositions,
                              children: [
                                Node(
                                    label: "1.1.1",
                                    nodePositions: _nodePositions),
                                Node(
                                    label: "1.1.1",
                                    nodePositions: _nodePositions),
                                Node(
                                    label: "1.1.1",
                                    nodePositions: _nodePositions),
                              ],
                            ),
                            Node(
                                label: 'Child 1.2',
                                nodePositions: _nodePositions),
                            Node(
                                label: 'Child 1.2',
                                nodePositions: _nodePositions),
                          ],
                        ),
                        Node(
                          label: 'Child 2',
                          nodePositions: _nodePositions,
                          children: [
                            Node(
                                label: 'Child 2.1',
                                nodePositions: _nodePositions),
                            Node(
                                label: 'Child 2.1',
                                nodePositions: _nodePositions),
                          ],
                        ),
                        Node(
                          label: 'Child 3',
                          nodePositions: _nodePositions,
                          children: [
                            Node(
                                label: 'Child 3.1',
                                nodePositions: _nodePositions),
                            Node(
                                label: 'Child 3.1',
                                nodePositions: _nodePositions),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Node extends StatefulWidget {
  final String label;
  final List<Node>? children;
  final Map<GlobalKey, Offset> nodePositions;

  const Node(
      {super.key,
      required this.label,
      this.children,
      required this.nodePositions});

  @override
  _NodeState createState() => _NodeState();
}

class _NodeState extends State<Node> {
  bool _expanded = false;
  final GlobalKey _key = GlobalKey();

  @override
  void didUpdateWidget(Node oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePosition();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePosition();
    });
  }

  void _updatePosition() {
    final RenderBox? renderBox =
        _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final Offset position = renderBox.localToGlobal(Offset.zero);
      widget.nodePositions[_key] = position;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Container(
            key: _key,
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded && widget.children != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: widget.children!.map((child) => child).toList(),
          ),
      ],
    );
  }
}

class NodePainter extends CustomPainter {
  final Map<GlobalKey, Offset> nodePositions;

  NodePainter({required this.nodePositions});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    _drawStraightLines(canvas, paint);
  }

  void _drawStraightLines(Canvas canvas, Paint paint) {
    nodePositions.forEach((key, position) {
      final nodeState = key.currentState as _NodeState?;
      if (nodeState != null &&
          nodeState._expanded &&
          nodeState.widget.children != null) {
        for (var child in nodeState.widget.children!) {
          final childPosition = nodePositions[child.key];
          if (childPosition != null) {
            canvas.drawLine(
              Offset(position.dx + 50, position.dy + 20),
              Offset(childPosition.dx + 50, childPosition.dy),
              paint,
            );
          }
        }
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
