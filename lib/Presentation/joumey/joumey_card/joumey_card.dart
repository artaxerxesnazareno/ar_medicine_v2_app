import 'package:ar_demo_ti/Presentation/theme/theme.dart';
import 'package:ar_demo_ti/models/jornada_model.dart';
import 'package:flutter/material.dart';

class JourneyCard extends StatefulWidget {
  final Jornada jornada;
  final VoidCallback onTap;

  const JourneyCard({
    super.key,
    required this.jornada,
    required this.onTap,
  });

  @override
  State<JourneyCard> createState() => _JourneyCardState();
}

class _JourneyCardState extends State<JourneyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
      _controller.forward();
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
      _controller.reverse();
    });
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.jornada.progresso;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top section with image and gradient overlay
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Journey image
                    Image.network(
                      widget.jornada.imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          width: double.infinity,
                          color: AppColors.primaryColor.withOpacity(0.2),
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.primaryColor,
                            size: 40,
                          ),
                        );
                      },
                    ),

                    // Gradient overlay
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),

                    // Journey title
                    Positioned(
                      bottom: 15,
                      left: 15,
                      right: 15,
                      child: Text(
                        widget.jornada.titulo,
                        style: TextStyle(
                          color: AppColors.lightText,
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 3,
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom section with description and progress
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 15),
                decoration: BoxDecoration(
                  color: AppColors.whiteShade,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.jornada.descricao,
                      style: TextStyle(
                        color: AppColors.darkText,
                        fontSize: isSmallScreen ? 12 : 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 15),
                    // Em telas muito pequenas, os chips ficam em coluna
                    isSmallScreen && screenWidth < 300
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoChip(
                                Icons.timer,
                                '${widget.jornada.tempoEstimado} min',
                              ),
                              const SizedBox(height: 6),
                              _buildInfoChip(
                                Icons.quiz,
                                '${widget.jornada.testes.length} testes',
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              _buildInfoChip(
                                Icons.timer,
                                '${widget.jornada.tempoEstimado} min',
                              ),
                              const SizedBox(width: 10),
                              _buildInfoChip(
                                Icons.quiz,
                                '${widget.jornada.testes.length} testes',
                              ),
                            ],
                          ),
                    SizedBox(height: isSmallScreen ? 12 : 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progresso',
                              style: TextStyle(
                                color: AppColors.darkText,
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildProgressBar(progress),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10, 
        vertical: isSmallScreen ? 4 : 5
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSmallScreen ? 12 : 14,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: isSmallScreen ? 4 : 6),
          Text(
            text,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: AppColors.progressBarBackground,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        minHeight: 6,
      ),
    );
  }
}
