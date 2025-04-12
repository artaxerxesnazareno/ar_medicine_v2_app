import 'package:ar_demo_ti/Presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class QuizResultWidget extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int passingScore; // percentage
  final VoidCallback onRetakeQuiz;
  final VoidCallback onContinue;

  const QuizResultWidget({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.passingScore,
    required this.onRetakeQuiz,
    required this.onContinue,
  });

  @override
  State<QuizResultWidget> createState() => _QuizResultWidgetState();
}

class _QuizResultWidgetState extends State<QuizResultWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    final percentage = widget.score / 100.0; // score is already a percentage
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: percentage,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isPassed {
    return widget.score >= widget.passingScore;
  }

  String get _feedbackTitle {
    final percentage = widget.score;

    if (percentage >= 90) {
      return 'Excelente!';
    } else if (percentage >= 80) {
      return 'Muito Bom!';
    } else if (percentage >= widget.passingScore) {
      return 'Bom Trabalho!';
    } else if (percentage >= 50) {
      return 'Quase Lá!';
    } else {
      return 'Continue Tentando';
    }
  }

  String get _feedbackMessage {
    final percentage = widget.score;

    if (percentage >= 90) {
      return 'Você dominou este conteúdo! Continue assim!';
    } else if (percentage >= 80) {
      return 'Você tem um ótimo conhecimento sobre este assunto!';
    } else if (percentage >= widget.passingScore) {
      return 'Você passou no teste e está no caminho certo para dominar este conteúdo.';
    } else if (percentage >= 50) {
      return 'Você quase passou! Revise o conteúdo e tente novamente.';
    } else {
      return 'Você pode melhorar! Revise o conteúdo e pratique mais.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final acertos = (widget.score * widget.totalQuestions / 100).round();
    final erros = widget.totalQuestions - acertos;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation for success or try again
          SizedBox(
            height: 200,
            child: _isPassed
                ? Lottie.network(
                    'https://assets5.lottiefiles.com/packages/lf20_touohxv0.json', // Success animation
                    repeat: false,
                  )
                : Lottie.network(
                    'https://assets9.lottiefiles.com/packages/lf20_qpwbiyxf.json', // Try again animation
                    repeat: true,
                  ),
          ),
          const SizedBox(height: 24),

          // Score title and subtitle
          Text(
            _feedbackTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color:
                  _isPassed ? AppColors.primaryColor : AppColors.warningColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _feedbackMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.darkText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 30),

          // Animated circular progress indicator
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: _progressAnimation.value,
                      strokeWidth: 12,
                      backgroundColor: AppColors.progressBarBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isPassed
                            ? AppColors.successColor
                            : AppColors.warningColor,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.score}%',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$acertos/${widget.totalQuestions} acertos',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.grayShade,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 40),

          // Score details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.grayShade.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                _buildScoreDetailRow(
                  'Acertos',
                  '$acertos',
                  Icons.check_circle,
                  AppColors.successColor,
                ),
                const SizedBox(height: 12),
                _buildScoreDetailRow(
                  'Erros',
                  '$erros',
                  Icons.cancel,
                  AppColors.errorColor,
                ),
                const SizedBox(height: 12),
                _buildScoreDetailRow(
                  'Nota Mínima',
                  '${widget.passingScore}%',
                  Icons.trending_up,
                  AppColors.secondaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Action buttons
          Row(
            children: [
              if (!_isPassed) ...[
                // Retake quiz button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onRetakeQuiz,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Tentar Novamente'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // Continue button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onContinue,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(_isPassed ? 'Continuar' : 'Revisar Conteúdo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.lightText,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetailRow(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}
