import 'package:ar_demo_ti/Presentation/theme/theme.dart';
import 'package:ar_demo_ti/models/conteudo_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ARViewScreen extends StatefulWidget {
  final ArContent arContent;

  const ARViewScreen({super.key, required this.arContent});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen>
    with SingleTickerProviderStateMixin {
  bool _isARReady = false;
  bool _isInfoPanelExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _infoSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initAR();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _infoSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.value = 1.0; // Start expanded
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Here you would dispose of AR-related resources
    super.dispose();
  }

  Future<void> _initAR() async {
    // Simulate AR initialization
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isARReady = true;
      });
    }
  }

  void _toggleInfoPanel() {
    setState(() {
      _isInfoPanelExpanded = !_isInfoPanelExpanded;
      if (_isInfoPanelExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set preferred orientation to landscape for better AR experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.lightText,
          ),
          onPressed: () {
            // Reset orientation when leaving
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: AppColors.lightText,
            ),
            onPressed: _toggleInfoPanel,
          ),
          IconButton(
            icon: Icon(
              Icons.fullscreen,
              color: AppColors.lightText,
            ),
            onPressed: () {
              // Toggle fullscreen
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // AR View (placeholder)
          Container(
            color: AppColors.arSceneBackground,
            child: Center(
              child: !_isARReady
                  ? _buildLoadingIndicator()
                  : _buildARPlaceholder(),
            ),
          ),

          // Sliding Info Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _infoSlideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    (1.0 - _infoSlideAnimation.value) *
                        200, // Slide up/down amount
                  ),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.whiteShade.withOpacity(0.9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.arContent.title,
                          style: AppFont.title,
                        ),
                        IconButton(
                          icon: Icon(
                            _isInfoPanelExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: AppColors.darkText,
                          ),
                          onPressed: _toggleInfoPanel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.arContent.description,
                      style: AppFont.bodyText,
                    ),
                    const SizedBox(height: 15),
                    _buildARControlsRow(),
                  ],
                ),
              ),
            ),
          ),

          // AR Instructions Overlay (shown when loading)
          if (!_isARReady)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.whiteShade.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.view_in_ar,
                      size: 60,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Preparando Experiu00eancia de Realidade Aumentada',
                      style: AppFont.subtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Aponte sua cu00e2mera para uma superfu00edcie plana e mova lentamente para iniciar.',
                      style: AppFont.bodyText,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _isARReady
          ? FloatingActionButton(
              onPressed: () {
                // Reset AR placement
              },
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.refresh),
            )
          : null,
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 20),
        Text(
          'Inicializando AR...',
          style: TextStyle(color: AppColors.darkText),
        ),
      ],
    );
  }

  Widget _buildARPlaceholder() {
    // In a real app, this would be replaced with actual AR implementation
    // using ARCore or ARKit plugins
    return Stack(
      children: [
        // Simulate AR background
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.view_in_ar,
                size: 100,
                color: AppColors.secondaryColor.withOpacity(0.7),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.whiteShade.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Modelo 3D: ${widget.arContent.arModelName}',
                  style: TextStyle(color: AppColors.darkText, fontSize: 16),
                ),
              ),
            ],
          ),
        ),

        // AR guidance indicators
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.touch_app,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Toque para posicionar o modelo',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildARControlsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildControlButton(
          icon: Icons.zoom_in,
          label: 'Ampliar',
          onPressed: () {
            // Zoom in
          },
        ),
        _buildControlButton(
          icon: Icons.zoom_out,
          label: 'Reduzir',
          onPressed: () {
            // Zoom out
          },
        ),
        _buildControlButton(
          icon: Icons.rotate_90_degrees_ccw,
          label: 'Girar',
          onPressed: () {
            // Rotate
          },
        ),
        _buildControlButton(
          icon: Icons.screenshot,
          label: 'Capturar',
          onPressed: () {
            // Capture screenshot
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Captura de tela salva!'),
                backgroundColor: AppColors.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.secondaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
