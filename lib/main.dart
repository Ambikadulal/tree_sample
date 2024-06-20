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
  final Map<NodeData, bool> _expandedNodes = {};

  final NodeData _parentNode = NodeData(
    key: GlobalKey(),
    label: 'Parent Node',
    children: [
      NodeData(
        key: GlobalKey(),
        label: 'Child 1',
      ),
      NodeData(
        key: GlobalKey(),
        label: 'Child 2',
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _initializeExpandedNodes(_parentNode);
  }

  void _initializeExpandedNodes(NodeData node) {
    _expandedNodes[node] = true;
    for (var child in node.children) {
      _initializeExpandedNodes(child);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hierarchical Nodes'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
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
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Node(
                          key: _parentKey,
                          data: _parentNode,
                          nodePositions: _nodePositions,
                          expandedNodes: _expandedNodes,
                          onAddChild: _addChild,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addChild(NodeData parentNode, String childLabel) {
    setState(() {
      final newNode = NodeData(
        key: GlobalKey(),
        label: childLabel,
      );
      parentNode.addChild(newNode);
      _expandedNodes[newNode] = true; // Automatically expand new nodes
    });
  }
}

class NodeData {
  final GlobalKey key;
  final String label;
  final List<NodeData> children;

  NodeData({
    required this.key,
    required this.label,
    List<NodeData>? children,
  }) : children = children ?? [];

  void addChild(NodeData child) {
    children.add(child);
  }
}

class Node extends StatefulWidget {
  final NodeData data;
  final Map<GlobalKey, Offset> nodePositions;
  final Map<NodeData, bool> expandedNodes;
  final void Function(NodeData parentNode, String childLabel) onAddChild;

  const Node({
    super.key,
    required this.data,
    required this.nodePositions,
    required this.expandedNodes,
    required this.onAddChild,
  });

  @override
  _NodeState createState() => _NodeState();
}

class _NodeState extends State<Node> {
  bool _expanded = false;
  late final GlobalKey _key;

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
    _key = widget.data.key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePosition();
    });
    _expanded = widget.expandedNodes[widget.data]!;
  }

  void _updatePosition() {
    final RenderBox? renderBox =
        _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final Offset position = renderBox.localToGlobal(Offset.zero);
      widget.nodePositions[_key] = position;
    }
  }

  void _showAddChildDialog() {
    final TextEditingController childNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Child Node'),
          content: TextField(
            controller: childNameController,
            decoration: const InputDecoration(
              labelText: 'Child Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (childNameController.text.isNotEmpty) {
                  widget.onAddChild(
                    widget.data,
                    childNameController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
              widget.expandedNodes[widget.data] = _expanded;
            });
          },
          child: Container(
            key: ObjectKey(UniqueKey()),
            padding: const EdgeInsets.all(8.0),
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
                  widget.data.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: _showAddChildDialog,
                ),
              ],
            ),
          ),
        ),
        if (_expanded && widget.data.children.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: widget.data.children
                .map((child) => Node(
                      key: child.key,
                      data: child,
                      nodePositions: widget.nodePositions,
                      expandedNodes: widget.expandedNodes,
                      onAddChild: widget.onAddChild,
                    ))
                .toList(),
          ),
      ],
    );
  }
}
/// this class might be use in future for drawing the directed lines
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
          nodeState.widget.data.children.isNotEmpty) {
        for (var child in nodeState.widget.data.children) {
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
