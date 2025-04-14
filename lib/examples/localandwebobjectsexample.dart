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
  
  // Novas variáveis para controlar a interface
  bool _controlsVisible = true;
  int _currentStep = 0;
  List<Map<String, String>> _procedureSteps = [
    {
      'title': '1. Visão Geral do Coração',
      'description': 'O coração humano é um órgão muscular responsável por bombear sangue para todo o corpo. Posicione o modelo 3D e observe sua estrutura completa.'
    },
    {
      'title': '2. Câmaras Cardíacas',
      'description': 'O coração possui quatro câmaras: dois átrios (superiores) e dois ventrículos (inferiores). Ajuste o tamanho para visualizar estas estruturas claramente.'
    },
    {
      'title': '3. Valvas Cardíacas',
      'description': 'As valvas controlam o fluxo sanguíneo unidirecional: tricúspide (entre átrio e ventrículo direitos), mitral (entre átrio e ventrículo esquerdos), pulmonar e aórtica.'
    },
    {
      'title': '4. Sistema de Condução',
      'description': 'Observe o nódulo sinoatrial (marca-passo natural), nódulo atrioventricular e o feixe de His que coordenam os batimentos cardíacos.'
    },
    {
      'title': '5. Circulação Coronariana',
      'description': 'As artérias coronárias (direita e esquerda) fornecem sangue ao músculo cardíaco. A obstrução destas artérias pode causar infarto do miocárdio.'
    },
    {
      'title': '6. Grandes Vasos',
      'description': 'Identifique a aorta, artéria pulmonar, veias pulmonares e veias cavas que conectam o coração ao sistema circulatório sistêmico e pulmonar.'
    },
  ];

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
    // Adaptação para diferentes tamanhos de tela
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;
    final isSmallScreen = screenSize.width < 360;
    
    // Cálculos de tamanho para os painéis
    final informationPanelWidth = isLargeScreen 
        ? screenSize.width * 0.35 
        : isSmallScreen
            ? screenSize.width * 0.6
            : screenSize.width * 0.45;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.favorite, color: Color(0xFFE91E63), size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.title == "Objeto 3D" ? 'Anatomia Cardíaca em 3D' : widget.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2C6BAD),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showExplanationDialog,
            tooltip: 'Informações sobre o coração',
          ),
        ],
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          // Indicador de progresso
          Center(
            child: CircularProgressIndicator(
              strokeWidth: 10,
              backgroundColor:
                  const Color.fromARGB(0, 255, 255, 255).withOpacity(0),
              valueColor: progressvalueColor,
              value: progress,
            )
          ),
          // Painel de passos do procedimento médico
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 20,
            right: _controlsVisible ? 20 : -informationPanelWidth - 20,
            width: informationPanelWidth,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite_border,
                                size: 18,
                                color: Color(0xFF2C6BAD),
                              ),
                              const SizedBox(width: 4),
                              const Flexible(
                                child: Text(
                                  'Anatomia Cardíaca',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF2C6BAD),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(_currentStep > 0 
                                  ? Icons.arrow_back_ios 
                                  : Icons.arrow_back_ios,
                                  color: _currentStep > 0 
                                      ? const Color(0xFF2C6BAD) 
                                      : Colors.grey),
                              onPressed: _currentStep > 0 
                                  ? () => setState(() => _currentStep--) 
                                  : null,
                              iconSize: 14,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                            ),
                            Text(
                              "${_currentStep + 1}/${_procedureSteps.length}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF2C6BAD),
                              ),
                            ),
                            IconButton(
                              icon: Icon(_currentStep < _procedureSteps.length - 1 
                                  ? Icons.arrow_forward_ios 
                                  : Icons.arrow_forward_ios,
                                  color: _currentStep < _procedureSteps.length - 1 
                                      ? const Color(0xFF2C6BAD) 
                                      : Colors.grey),
                              onPressed: _currentStep < _procedureSteps.length - 1 
                                  ? () => setState(() => _currentStep++) 
                                  : null,
                              iconSize: 14,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FC),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: const Color(0xFFE0E9F5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _procedureSteps[_currentStep]['title']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 12 : 13,
                              color: const Color(0xFF2C6BAD),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 2 : 4),
                          Text(
                            _procedureSteps[_currentStep]['description']!,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: const Color(0xFF4A6585),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Controles para o objeto
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _controlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFF2C6BAD).withOpacity(0.8),
                      const Color(0xFF2C6BAD).withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 0.6, 1.0],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, top: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildBottomControlGroup(
                                      title: 'Tamanho',
                                      children: [
                                        _buildControlButton(
                                          icon: Icons.remove,
                                          onPressed: _decreaseScale,
                                          tooltip: 'Diminuir escala',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildControlButton(
                                          icon: Icons.add,
                                          onPressed: _increaseScale,
                                          tooltip: 'Aumentar escala',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    _buildBottomControlGroup(
                                      title: 'Rotação',
                                      children: [
                                        _buildControlButton(
                                          icon: Icons.rotate_left,
                                          onPressed: () => _toggleRotation(0),
                                          tooltip: 'Rotação eixo X',
                                          isActive: moving?.isrotate?[0] ?? false,
                                        ),
                                        const SizedBox(width: 8),
                                        _buildControlButton(
                                          icon: Icons.rotate_90_degrees_ccw,
                                          onPressed: () => _toggleRotation(1),
                                          tooltip: 'Rotação eixo Y',
                                          isActive: moving?.isrotate?[1] ?? false,
                                        ),
                                        const SizedBox(width: 8),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Botão para mostrar/ocultar controles
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              heroTag: 'visibilityButton',
              onPressed: () {
                setState(() {
                  _controlsVisible = !_controlsVisible;
                });
              },
              backgroundColor: const Color(0xFF2C6BAD),
              foregroundColor: Colors.white,
              elevation: 4,
              child: Icon(_controlsVisible ? Icons.visibility_off : Icons.visibility),
              tooltip: _controlsVisible ? 'Ocultar controles' : 'Mostrar controles',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControlGroup({
    required String title,
    required List<Widget> children,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12, 
        vertical: isSmallScreen ? 6 : 8
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                title == 'Tamanho' ? Icons.zoom_in : Icons.rotate_right,
                size: isSmallScreen ? 12 : 14,
                color: const Color(0xFF2C6BAD),
              ),
              SizedBox(width: isSmallScreen ? 2 : 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C6BAD),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Wrap(
            spacing: isSmallScreen ? 4 : 8,
            children: children,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final buttonSize = isSmallScreen ? 32.0 : 36.0;
    
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.all(1),
        child: Material(
          color: isActive 
              ? const Color(0xFF2C6BAD) 
              : Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          elevation: isActive ? 3 : 1,
          shadowColor: isActive
              ? const Color(0xFF2C6BAD).withOpacity(0.4)
              : Colors.black12,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: isActive 
                      ? const Color(0xFF2C6BAD) 
                      : const Color(0xFFD0DFF2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: isSmallScreen ? 14 : 16,
                  color: isActive 
                      ? Colors.white 
                      : const Color(0xFF2C6BAD),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showExplanationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Anatomia do Coração'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Este modelo 3D permite a visualização detalhada da estrutura cardíaca humana, possibilitando o estudo da anatomia e fisiologia do coração.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Estruturas Principais:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildInstructionItem(
                  'Câmaras: Átrios direito e esquerdo, ventrículos direito e esquerdo.',
                ),
                _buildInstructionItem(
                  'Valvas: Tricúspide, mitral, pulmonar e aórtica.',
                ),
                _buildInstructionItem(
                  'Grandes vasos: Aorta, artéria pulmonar, veias pulmonares, veias cavas.',
                ),
                _buildInstructionItem(
                  'Músculo cardíaco: Miocárdio, epicárdio e endocárdio.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Instruções de Uso:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildInstructionItem(
                  'Toque na superfície plana para posicionar o modelo 3D do coração.',
                ),
                _buildInstructionItem(
                  'Use os botões + e - para ajustar o tamanho do modelo.',
                ),
                _buildInstructionItem(
                  'Utilize os botões de rotação para visualizar diferentes ângulos do coração.',
                ),
                _buildInstructionItem(
                  'Siga os passos do guia na parte superior para estudar cada aspecto da anatomia cardíaca.',
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
