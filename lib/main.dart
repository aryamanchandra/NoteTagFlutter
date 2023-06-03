import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:flutter_3d/flutter_3d.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteTag',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'NoteTag'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ArCoreController _arCoreController;
  double _distanceMoved = 0.0;
  List<ArCoreNode> _arCoreNodes = [];

  _onArCoreViewCreated(ArCoreController arCoreController) {
    _arCoreController = arCoreController;
    _addText(_arCoreController);
  }

  _addText(ArCoreController arCoreController) {
    final text = Text(
      'Hello World',
      style: TextStyle(
        fontSize: 24.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
    final textWidget = Widget3D(child: text, scale: vector.Vector3.all(0.1));
    final node = ArCoreNode(
      shape: textWidget,
      position: vector.Vector3(0, 0, -1),
    );

    _arCoreNodes.add(node);
    arCoreController.addArCoreNode(node);
  }

  _moveShapes(double delta) {
    final double distance = delta * 3.0;

    _moveShapeAhead(distance); // Move shapes ahead
    _moveShapeBack(-distance); // Move shapes back

    setState(() {
      _distanceMoved += distance;
    });
  }

  _moveShapeAhead(double distance) {
    final List<ArCoreNode> updatedNodes = [];

    for (final node in _arCoreNodes) {
      final currentPosition = node.position!.value;
      final newPosition = vector.Vector3(
        currentPosition.x,
        currentPosition.y,
        currentPosition.z + distance,
      );

      final updatedNode = ArCoreNode(
        shape: node.shape,
        position: newPosition,
      );

      updatedNodes.add(updatedNode);

      _arCoreController.removeNode(nodeName: node.name!);
      _arCoreController.addArCoreNode(updatedNode);
    }

    _arCoreNodes = updatedNodes;
  }

  _moveShapeBack(double distance) {
    final List<ArCoreNode> updatedNodes = [];

    for (final node in _arCoreNodes) {
      final currentPosition = node.position!.value;
      final newPosition = vector.Vector3(
        currentPosition.x,
        currentPosition.y,
        currentPosition.z - distance,
      );

      final updatedNode = ArCoreNode(
        shape: node.shape,
        position: newPosition,
      );

      updatedNodes.add(updatedNode);

      _arCoreController.removeNode(nodeName: node.name!);
      _arCoreController.addArCoreNode(updatedNode);
    }

    _arCoreNodes = updatedNodes;
  }

  @override
  void dispose() {
    _arCoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          final double sensitivity = 0.01;
          final double delta = details.delta.dy * sensitivity;

          _moveShapes(delta);
        },
        child: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Distance moved: $_distanceMoved',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
