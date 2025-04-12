import 'package:ar_demo_ti/Presentation/quiz/quiz_result_widget.dart';
import 'package:ar_demo_ti/Presentation/theme/theme.dart';
import 'package:ar_demo_ti/models/teste_model.dart';
import 'package:ar_demo_ti/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatefulWidget {
  final Teste teste;

  const QuizScreen({
    super.key,
    required this.teste,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  bool _isAnswered = false;
  bool _isLastQuestion = false;
  bool _showExplanation = false;
  int _score = 0;
  List<int> _userAnswers = [];

  // Animation controller for page transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initQuiz();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
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

  void _initQuiz() {
    _userAnswers = List.filled(widget.teste.perguntas.length, -1);
    setState(() {
      _isLastQuestion =
          _currentQuestionIndex == widget.teste.perguntas.length - 1;
    });
  }

  void _selectAnswer(int optionIndex) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _userAnswers[_currentQuestionIndex] = optionIndex;

      // Check if answer is correct and update score
      if (optionIndex ==
          widget.teste.perguntas[_currentQuestionIndex]['respostaCorreta']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_isLastQuestion) {
      _finishQuiz();
      return;
    }

    // Reset and move to next question with animation
    _animationController.reset();

    setState(() {
      _currentQuestionIndex++;
      _isAnswered = _userAnswers[_currentQuestionIndex] != -1;
      _showExplanation = false;
      _isLastQuestion =
          _currentQuestionIndex == widget.teste.perguntas.length - 1;
    });

    _animationController.forward();
  }

  void _toggleExplanation() {
    setState(() {
      _showExplanation = !_showExplanation;
    });
  }

  void _finishQuiz() async {
    final appState = Provider.of<AppState>(context, listen: false);

    if (appState.userId != null) {
      // Submit test and get score
      final score =
          await widget.teste.realizarTeste(appState.userId!, _userAnswers);

      // Show results screen
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Resultado do Teste'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: QuizResultWidget(
              score: score.pontuacao,
              totalQuestions: widget.teste.perguntas.length,
              passingScore: widget.teste.notaAprovacao,
              onRetakeQuiz: () {
                // Reset the quiz and start over
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(teste: widget.teste),
                  ),
                );
              },
              onContinue: () {
                // Return to the previous screen
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      );
    } else {
      // If no user ID (shouldn't happen), just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao salvar resultado do teste.'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> question =
        widget.teste.perguntas[_currentQuestionIndex];
    final List<String> options = List<String>.from(question['opcoes']);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teste.titulo),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Questão ${_currentQuestionIndex + 1}/${widget.teste.perguntas.length}',
                style: AppFont.regularBoldDark.copyWith(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value:
                  (_currentQuestionIndex + 1) / widget.teste.perguntas.length,
              backgroundColor: AppColors.progressBarBackground,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              minHeight: 6,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildQuestionCard(question),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildOptionsColumn(
                            options, question['respostaCorreta']),
                      ),
                    ),
                    if (_isAnswered && _showExplanation) ...[
                      const SizedBox(height: 20),
                      _buildExplanationCard(question['explicacao']),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questão ${_currentQuestionIndex + 1}:',
            style: TextStyle(
              color: AppColors.lightText.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            question['texto'],
            style: TextStyle(
              color: AppColors.lightText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsColumn(List<String> options, int correctAnswerIndex) {
    return Column(
      children: List.generate(options.length, (index) {
        return _buildOptionCard(
          option: options[index],
          index: index,
          isSelected: _userAnswers[_currentQuestionIndex] == index,
          isCorrect: index == correctAnswerIndex,
          showCorrect: _isAnswered,
        );
      }),
    );
  }

  Widget _buildOptionCard({
    required String option,
    required int index,
    required bool isSelected,
    required bool isCorrect,
    required bool showCorrect,
  }) {
    // Determine the card color based on selection and correctness
    Color cardColor = AppColors.cardBackground;
    Color borderColor = AppColors.quizOptionBorder;
    IconData? trailingIcon;
    Color? iconColor;

    if (showCorrect) {
      if (isCorrect) {
        cardColor = AppColors.successColor.withOpacity(0.1);
        borderColor = AppColors.successColor;
        trailingIcon = Icons.check_circle;
        iconColor = AppColors.successColor;
      } else if (isSelected && !isCorrect) {
        cardColor = AppColors.errorColor.withOpacity(0.1);
        borderColor = AppColors.errorColor;
        trailingIcon = Icons.cancel;
        iconColor = AppColors.errorColor;
      }
    } else if (isSelected) {
      cardColor = AppColors.primaryColor.withOpacity(0.1);
      borderColor = AppColors.primaryColor;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Option index circle
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.grayShade.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    color:
                        isSelected ? AppColors.lightText : AppColors.darkText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Option text
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: AppColors.darkText,
                  fontSize: 16,
                  height: 1.3,
                ),
              ),
            ),

            // Trailing icon (check or cancel) when answered
            if (showCorrect && (isCorrect || isSelected))
              Icon(trailingIcon, color: iconColor, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard(String explanation) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: AppColors.warningColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Explicação',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteShade,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_isAnswered) ...[
            // Explanation toggle button
            OutlinedButton.icon(
              onPressed: _toggleExplanation,
              icon: Icon(
                _showExplanation ? Icons.visibility_off : Icons.visibility,
                size: 18,
              ),
              label: Text(_showExplanation ? 'Ocultar' : 'Explicação'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(width: 10),
          ],

          // Next or Finish button
          Expanded(
            child: ElevatedButton(
              onPressed: _isAnswered ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.lightText,
                disabledBackgroundColor: AppColors.grayShade,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(_isLastQuestion ? 'Finalizar' : 'Próxima'),
            ),
          ),
        ],
      ),
    );
  }
}
