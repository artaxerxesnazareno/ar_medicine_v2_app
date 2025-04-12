import 'dart:async';

import 'package:ar_demo_ti/movingobjects.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

class LocalAndWebObjectsWidget extends StatefulWidget {
  final String uri;
  final vector_math.Vector3 scale;
  final String title;
  final String description;

  LocalAndWebObjectsWidget({
    Key? key,
    required this.uri,
    vector_math.Vector3? scale,
    this.title = "Objeto 3D",
    this.description = "Visualização de um objeto 3D em realidade aumentada.",
  })  : scale = scale ?? vector_math.Vector3(0.2, 0.2, 0.2),
        super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LocalAndWebObjectsWidgetState createState() =>
      _LocalAndWebObjectsWidgetState();
}

class _LocalAndWebObjectsWidgetState extends State<LocalAndWebObjectsWidget> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;
  List<ARAnchor> anchors = [];
  List<ARNode> nodes = [];
  ARNode? newNode;
  MovingObject? moving;
  double? progress = 0;
  bool _stopTimer = false;
  bool _stopTimerRotation = false;
  int elapsedMs = 500;
  Timer? timerrot;
  AlwaysStoppedAnimation<Color>? progressvalueColor =
      const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 252, 1, 1));
  vector_math.Vector3 currentScale = vector_math.Vector3(0.2, 0.2, 0.2);
  bool autoRotate = false;
  int rotationAxis = 1; // 0 = x, 1 = y, 2 = z

  @override
  void initState() {
    super.initState();
    currentScale = widget.scale;
    moving = MovingObject(
        webObjectNode: null,
        webAnchor: null,
        position: vector_math.Vector3.zero(),
        rotation: vector_math.Vector3.zero(),
        isrotate: [false, false, false]);
    timerrot = Timer.periodic(Duration(milliseconds: elapsedMs), (timerrot) {
      try {
        if (_stopTimerRotation) {
          timerrot.cancel();
        } else {
          if (moving!.webObjectNode != null) {
            rotobject();
          }
        }
      } catch (error) {
        rethrow;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    stopTimerRotation();
    timerrot?.cancel();
    stopTimer();
    arSessionManager!.dispose();
    progressvalueColor = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realidade Aumentada'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showExplanationDialog,
            tooltip: 'Informações sobre o objeto',
          ),
        ],
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          Center(
              child: CircularProgressIndicator(
            strokeWidth: 10,
            backgroundColor:
                const Color.fromARGB(0, 255, 255, 255).withOpacity(0),
            valueColor: progressvalueColor,
            value: progress,
          )),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildControlButton(
                            icon: Icons.remove,
                            onPressed: _decreaseScale,
                            tooltip: 'Diminuir escala',
                          ),
                          _buildControlButton(
                            icon: Icons.add,
                            onPressed: _increaseScale,
                            tooltip: 'Aumentar escala',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildControlButton(
                            icon: Icons.rotate_left,
                            onPressed: () => _toggleRotation(0),
                            tooltip: 'Rotação eixo X',
                            isActive: moving?.isrotate?[0] ?? false,
                          ),
                          _buildControlButton(
                            icon: Icons.rotate_90_degrees_ccw,
                            onPressed: () => _toggleRotation(1),
                            tooltip: 'Rotação eixo Y',
                            isActive: moving?.isrotate?[1] ?? false,
                          ),
                          _buildControlButton(
                            icon: Icons.rotate_right,
                            onPressed: () => _toggleRotation(2),
                            tooltip: 'Rotação eixo Z',
                            isActive: moving?.isrotate?[2] ?? false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isActive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.blue : null,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(16),
          elevation: 4,
        ),
        child: Icon(icon),
      ),
    );
  }

  void _showExplanationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Instruções:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildInstructionItem(
                  'Toque na superfície plana para posicionar o objeto 3D.',
                ),
                _buildInstructionItem(
                  'Use os botões + e - para ajustar o tamanho.',
                ),
                _buildInstructionItem(
                  'Ative as rotações nos diferentes eixos com os botões abaixo.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _increaseScale() {
    if (moving?.webObjectNode != null) {
      setState(() {
        currentScale = vector_math.Vector3(
          currentScale.x + 0.05,
          currentScale.y + 0.05,
          currentScale.z + 0.05,
        );
        _updateNodeScale();
      });
    }
  }

  void _decreaseScale() {
    if (moving?.webObjectNode != null) {
      if (currentScale.x > 0.1) {
        setState(() {
          currentScale = vector_math.Vector3(
            currentScale.x - 0.05,
            currentScale.y - 0.05,
            currentScale.z - 0.05,
          );
          _updateNodeScale();
        });
      }
    }
  }

  void _updateNodeScale() {
    if (moving?.webObjectNode != null) {
      Matrix4 newTransform = Matrix4.identity();
      newTransform.setTranslation(moving!.webObjectNode!.position);
      newTransform.rotate(vector_math.Vector3(1, 0, 0), moving!.rotation![0] * 3.1415927 / 180);
      newTransform.rotate(vector_math.Vector3(0, 1, 0), moving!.rotation![1] * 3.1415927 / 180);
      newTransform.rotate(vector_math.Vector3(0, 0, 1), moving!.rotation![2] * 3.1415927 / 180);
      newTransform.scale(currentScale.x, currentScale.y, currentScale.z);
      moving!.webObjectNode!.transform = newTransform;
    }
  }

  void _toggleRotation(int axis) {
    if (moving?.webObjectNode != null) {
      setState(() {
        // Parar todas as rotações
        if (moving!.isrotate![axis]) {
          moving!.isrotate![axis] = false;
        } else {
          // Parar outras rotações ao ativar uma
          moving!.isrotate = [false, false, false];
          moving!.isrotate![axis] = true;
        }
      });
    }
  }

  void rotobject() {
    try {
      setState(() {
        if (moving!.isrotate![0]) {
          if (moving!.rotation![0] > 360) {
            moving!.rotation![0] = 0;
          } else {
            moving!.rotation![0] = moving!.rotation![0] + 5;
          }
          Matrix4 newMatrix = Matrix4.copy(moving!.webObjectNode!.transform);
          newMatrix.rotate(
              vector_math.Vector3(1, 0, 0), moving!.rotation![0] * 3.1415927 / 180);
          moving!.webObjectNode!.transform = newMatrix;
        }
        if (moving!.isrotate![1]) {
          if (moving!.rotation![1] > 360) {
            moving!.rotation![1] = 0;
          } else {
            moving!.rotation![1] = moving!.rotation![1] + 5;
          }
          Matrix4 newMatrix = Matrix4.copy(moving!.webObjectNode!.transform);
          newMatrix.rotate(
              vector_math.Vector3(0, 1, 0), moving!.rotation![1] * 3.1415927 / 180);
          moving!.webObjectNode!.transform = newMatrix;
        }
        if (moving!.isrotate![2]) {
          if (moving!.rotation![2] > 360) {
            moving!.rotation![2] = 0;
          } else {
            moving!.rotation![2] = moving!.rotation![2] + 5;
          }
          Matrix4 newMatrix = Matrix4.copy(moving!.webObjectNode!.transform);
          newMatrix.rotate(
              vector_math.Vector3(0, 0, 1), moving!.rotation![2] * 3.1415927 / 180);
          moving!.webObjectNode!.transform = newMatrix;
        }
      });
    } catch (error) {
      rethrow;
    }
  }

  onPanStarted(String nodeName) {}

  onPanChanged(String nodeName) {}

  onPanEnded(String nodeName, Matrix4 newTransform) {}

  onRotationStarted(String nodeName) {}

  onRotationChanged(String nodeName) {}

  onRotationEnded(String nodeName, Matrix4 newTransform) {}

  Future<void> onPlaneOrPointTapped(
      List<ARHitTestResult> hitTestResults) async {
    if (moving!.webObjectNode != null) {
      arObjectManager!.removeNode(moving!.webObjectNode!);
      arAnchorManager!.removeAnchor(moving!.webAnchor!);
      moving!.webObjectNode = null;
      moving!.webAnchor = null;
    }
    try {
      if (widget.uri.isEmpty) return;

      var singleHitTestResult = hitTestResults.firstWhere(
          (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);

      // ignore: unrelated_type_equality_checks
      if (singleHitTestResult != ARHitTestResultType.undefined) {
        var newAnchor =
            ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
        bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
        if (didAddAnchor!) {
          anchors.add(newAnchor);
          // Add note to anchor
          progress = 0;
          startTimer(max: 6000);
          String uriitem = "https://${widget.uri}";
          var newNode = ARNode(
              type: NodeType.webGLB,
              uri: uriitem,
              scale: currentScale,
              position: vector_math.Vector3(0.0, 0.0, 0.0),
              rotation: vector_math.Vector4(1.0, 0.0, 0.0, 0.0));

          bool? didAddNodeToAnchor =
              await arObjectManager!.addNode(newNode, planeAnchor: newAnchor);
          if (didAddNodeToAnchor!) {
            nodes.add(newNode);
            moving!.webObjectNode = (didAddNodeToAnchor) ? newNode : null;
            moving!.webAnchor = newAnchor;
            stopTimer();
            startTimerRotation(elapsed: 500);
          } else {
            arSessionManager!.onError("Adding Node to Anchor failed");
          }
        } else {
          arSessionManager!.onError("Adding Anchor failed");
        }
      }
      // ignore: empty_catches
    } catch (error) {}
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
          showFeaturePoints: false,
          showPlanes: true,
          customPlaneTexturePath: "assets/triangle.png",
          showWorldOrigin: false,
          showAnimatedGuide: false,
          handleTaps: true,
          handleRotation: false,
        );
    this.arObjectManager!.onInitialize();

    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager!.onRotationStart = onRotationStarted;
    this.arObjectManager!.onRotationChange = onRotationChanged;
    this.arObjectManager!.onRotationEnd = onRotationEnded;

    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager!.onPanStart = onPanStarted;
    this.arObjectManager!.onPanChange = onPanChanged;
    this.arObjectManager!.onPanEnd = onPanEnded;
    this.arObjectManager!.onRotationStart = onRotationStarted;
    this.arObjectManager!.onRotationChange = onRotationChanged;
    this.arObjectManager!.onRotationEnd = onRotationEnded;
  }

  delayed(int sec) async {
    await Future.delayed(Duration(seconds: sec));
    return true;
  }

  void startTimer({double max = 0}) {
    _stopTimer = false;
    Timer.periodic(
      const Duration(milliseconds: 250),
      (Timer timer) => setState(
        () {
          if ((progress! >= max) || _stopTimer) {
            progress = 0;
            timer.cancel();
          } else {
            progress = progress! + 0.1;
          }
        },
      ),
    );
  }

  void stopTimer() {
    _stopTimer = true;
  }

  void startTimerRotation({int elapsed = 1000}) {
    _stopTimerRotation = false;
    elapsedMs = elapsed;
  }

  void stopTimerRotation() {
    _stopTimerRotation = true;
  }
}
