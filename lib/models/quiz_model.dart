class Quiz {
  final String id;
  final String moduleId;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final int passingScore; // Minimum percentage to pass

  Quiz({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.questions,
    this.passingScore = 70, // Default passing score is 70%
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      moduleId: json['moduleId'],
      title: json['title'],
      description: json['description'],
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
      passingScore: json['passingScore'] ?? 70,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'passingScore': passingScore,
    };
  }

  // Calculate the total possible score
  int get totalPossibleScore => questions.length;

  // Get sample quizzes for modules
  static Quiz getSampleQuiz(String moduleId) {
    // Based on module ID, return appropriate quiz
    switch (moduleId) {
      case '1-1': // Visão Geral da Anatomia Abdominal
        return Quiz(
          id: 'quiz-1-1',
          moduleId: '1-1',
          title: 'Quiz: Anatomia da Parede Abdominal',
          description:
              'Teste seus conhecimentos sobre as camadas e estruturas da parede abdominal.',
          questions: [
            QuizQuestion(
              id: 'q1-1-1',
              text:
                  'Qual das seguintes camadas NÃO faz parte da parede abdominal?',
              options: [
                QuizOption(text: 'Pele', isCorrect: false),
                QuizOption(text: 'Fáscia superficial', isCorrect: false),
                QuizOption(text: 'Peritônio', isCorrect: false),
                QuizOption(text: 'Epitélio alveolar', isCorrect: true),
              ],
              explanation:
                  'O epitélio alveolar é encontrado nos pulmões, não na parede abdominal. A parede abdominal consiste em pele, fáscia superficial, músculos, fáscia transversal e peritônio.',
            ),
            QuizQuestion(
              id: 'q1-1-2',
              text:
                  'Qual músculo forma a linha alba na parede abdominal anterior?',
              options: [
                QuizOption(text: 'Reto abdominal', isCorrect: false),
                QuizOption(text: 'Transverso do abdômen', isCorrect: false),
                QuizOption(text: 'Oblíquo externo', isCorrect: false),
                QuizOption(
                    text: 'É uma estrutura tendinosa, não muscular',
                    isCorrect: true),
              ],
              explanation:
                  'A linha alba é uma estrutura tendinosa formada pela fusão das aponeuroses dos músculos abdominais na linha média.',
            ),
            QuizQuestion(
              id: 'q1-1-3',
              text:
                  'Qual estrutura anatômica separa a cavidade abdominal da torácica?',
              options: [
                QuizOption(text: 'Diafragma', isCorrect: true),
                QuizOption(text: 'Peritônio', isCorrect: false),
                QuizOption(text: 'Fáscia transversal', isCorrect: false),
                QuizOption(text: 'Músculos intercostais', isCorrect: false),
              ],
              explanation:
                  'O diafragma é o músculo que separa a cavidade torácica da abdominal e é essencial para a respiração.',
            ),
            QuizQuestion(
              id: 'q1-1-4',
              text:
                  'Qual das seguintes estruturas está localizada no quadrante inferior direito do abdômen?',
              options: [
                QuizOption(text: 'Baço', isCorrect: false),
                QuizOption(text: 'Apêndice', isCorrect: true),
                QuizOption(text: 'Estômago', isCorrect: false),
                QuizOption(text: 'Rim esquerdo', isCorrect: false),
              ],
              explanation:
                  'O apêndice vermiforme está localizado no quadrante inferior direito do abdômen, conectado ao ceco do intestino grosso.',
            ),
            QuizQuestion(
              id: 'q1-1-5',
              text: 'Qual é a principal função do peritônio?',
              options: [
                QuizOption(
                    text:
                        'Fornecer suporte estrutural para os músculos abdominais',
                    isCorrect: false),
                QuizOption(
                    text: 'Secretar enzimas digestivas', isCorrect: false),
                QuizOption(
                    text: 'Reduzir a fricção entre órgãos abdominais',
                    isCorrect: true),
                QuizOption(
                    text: 'Armazenar gordura corporal', isCorrect: false),
              ],
              explanation:
                  'O peritônio é uma membrana serosa que reveste a cavidade abdominal e cobre a maioria dos órgãos abdominais. Sua principal função é reduzir a fricção entre órgãos e facilitar o movimento.',
            ),
          ],
        );

      case '2-1': // Fundamentos da Sutura
        return Quiz(
          id: 'quiz-2-1',
          moduleId: '2-1',
          title: 'Quiz: Fundamentos da Sutura',
          description:
              'Teste seus conhecimentos sobre os princípios básicos e materiais de sutura.',
          questions: [
            QuizQuestion(
              id: 'q2-1-1',
              text:
                  'Qual das seguintes NÃO é uma classificação de material de sutura?',
              options: [
                QuizOption(text: 'Absorvível', isCorrect: false),
                QuizOption(text: 'Não-absorvível', isCorrect: false),
                QuizOption(text: 'Monofilamentar', isCorrect: false),
                QuizOption(text: 'Extracelular', isCorrect: true),
              ],
              explanation:
                  'Os materiais de sutura são classificados como absorvíveis ou não-absorvíveis, e como monofilamentares ou multifilamentares. "Extracelular" não é uma classificação de material de sutura.',
            ),
            QuizQuestion(
              id: 'q2-1-2',
              text:
                  'Qual tipo de sutura é mais adequado para tecidos que precisam de suporte por longos períodos?',
              options: [
                QuizOption(text: 'Catgut simples', isCorrect: false),
                QuizOption(text: 'Poliglactina 910 (Vicryl)', isCorrect: false),
                QuizOption(text: 'Seda', isCorrect: true),
                QuizOption(
                    text: 'Poliglecaprone 25 (Monocryl)', isCorrect: false),
              ],
              explanation:
                  'A seda é um material não-absorvível que fornece suporte ao tecido por longos períodos, tornando-a adequada para tecidos que precisam de suporte prolongado.',
            ),
            QuizQuestion(
              id: 'q2-1-3',
              text:
                  'Qual destas é uma vantagem dos materiais de sutura monofilamentares sobre os multifilamentares?',
              options: [
                QuizOption(text: 'Maior força tensil', isCorrect: false),
                QuizOption(text: 'Melhor manuseio', isCorrect: false),
                QuizOption(text: 'Menor risco de infecção', isCorrect: true),
                QuizOption(text: 'Menor custo', isCorrect: false),
              ],
              explanation:
                  'Os materiais monofilamentares têm menor probabilidade de abrigar bactérias em comparação com os multifilamentares, resultando em menor risco de infecção.',
            ),
            QuizQuestion(
              id: 'q2-1-4',
              text:
                  'Qual é o propósito principal de um padrão de sutura interrompida?',
              options: [
                QuizOption(
                    text: 'Economizar material de sutura', isCorrect: false),
                QuizOption(
                    text: 'Fornecer maior resistência à tensão',
                    isCorrect: false),
                QuizOption(
                    text:
                        'Permitir ajustes na tensão após completar várias suturas',
                    isCorrect: false),
                QuizOption(
                    text:
                        'Prevenir que toda a linha se solte se um ponto falhar',
                    isCorrect: true),
              ],
              explanation:
                  'Um padrão de sutura interrompida usa pontos individuais, cada um com seu próprio nó. Se um ponto falhar, os outros permanecem intactos, prevenindo a deiscência completa da ferida.',
            ),
            QuizQuestion(
              id: 'q2-1-5',
              text:
                  'Qual das seguintes agulhas de sutura é mais adequada para tecidos delicados como vasos sanguíneos?',
              options: [
                QuizOption(text: 'Agulha cortante reversa', isCorrect: false),
                QuizOption(text: 'Agulha cortante', isCorrect: false),
                QuizOption(
                    text: 'Agulha cônica (atraumática)', isCorrect: true),
                QuizOption(text: 'Agulha de ponta romba', isCorrect: false),
              ],
              explanation:
                  'Agulhas cônicas (atraumáticas) separam o tecido em vez de cortá-lo, causando menos trauma, o que as torna ideais para estruturas delicadas como vasos sanguíneos.',
            ),
          ],
        );

      case '3-1': // Instrumentos Básicos
        return Quiz(
          id: 'quiz-3-1',
          moduleId: '3-1',
          title: 'Quiz: Instrumentação Cirúrgica Básica',
          description:
              'Teste seus conhecimentos sobre instrumentos cirúrgicos fundamentais.',
          questions: [
            QuizQuestion(
              id: 'q3-1-1',
              text:
                  'Qual instrumento é utilizado primariamente para segurar tecidos durante a dissecção?',
              options: [
                QuizOption(text: 'Pinça Kelly', isCorrect: false),
                QuizOption(text: 'Pinça Adson', isCorrect: true),
                QuizOption(text: 'Porta-agulhas', isCorrect: false),
                QuizOption(text: 'Tesoura Metzenbaum', isCorrect: false),
              ],
              explanation:
                  'A pinça Adson é uma pinça de dissecção utilizada para segurar delicadamente os tecidos durante procedimentos cirúrgicos.',
            ),
            QuizQuestion(
              id: 'q3-1-2',
              text:
                  'Qual instrumento é utilizado para hemostasia de vasos de pequeno e médio calibre?',
              options: [
                QuizOption(text: 'Pinça Kocher', isCorrect: false),
                QuizOption(text: 'Pinça Babcock', isCorrect: false),
                QuizOption(text: 'Pinça Kelly', isCorrect: true),
                QuizOption(text: 'Afastador Farabeuf', isCorrect: false),
              ],
              explanation:
                  'A pinça Kelly é uma pinça hemostática utilizada para clipar e ocluir vasos sanguíneos de pequeno e médio calibre durante procedimentos cirúrgicos.',
            ),
            QuizQuestion(
              id: 'q3-1-3',
              text:
                  'Qual instrumento é mais adequado para a dissecção de tecidos delicados?',
              options: [
                QuizOption(text: 'Tesoura Mayo', isCorrect: false),
                QuizOption(text: 'Tesoura Metzenbaum', isCorrect: true),
                QuizOption(text: 'Tesoura Spencer', isCorrect: false),
                QuizOption(text: 'Tesoura de fios', isCorrect: false),
              ],
              explanation:
                  'A tesoura Metzenbaum possui lâminas longas e delicadas, ideais para a dissecção precisa de tecidos delicados e planos teciduais.',
            ),
            QuizQuestion(
              id: 'q3-1-4',
              text: 'Qual é a principal função de um porta-agulhas?',
              options: [
                QuizOption(text: 'Cortar tecidos', isCorrect: false),
                QuizOption(
                    text: 'Segurar e manipular agulhas de sutura',
                    isCorrect: true),
                QuizOption(text: 'Afastar tecidos', isCorrect: false),
                QuizOption(text: 'Promover hemostasia', isCorrect: false),
              ],
              explanation:
                  'O porta-agulhas é especificamente projetado para segurar e manipular agulhas de sutura com precisão durante o processo de sutura de tecidos.',
            ),
            QuizQuestion(
              id: 'q3-1-5',
              text:
                  'Qual instrumento é primariamente utilizado para afastar tecidos durante a cirurgia?',
              options: [
                QuizOption(text: 'Afastador Richardson', isCorrect: true),
                QuizOption(text: 'Pinça Allis', isCorrect: false),
                QuizOption(text: 'Pinça Backhaus', isCorrect: false),
                QuizOption(text: 'Cabo de bisturi', isCorrect: false),
              ],
              explanation:
                  'O afastador Richardson é um tipo de afastador manual utilizado para retrair tecidos e expor o campo operatório durante procedimentos cirúrgicos.',
            ),
          ],
        );

      default:
        // Default quiz if module ID doesn't match any specific quiz
        return Quiz(
          id: 'default-quiz',
          moduleId: moduleId,
          title: 'Quiz de Avaliação',
          description: 'Teste seus conhecimentos sobre este módulo.',
          questions: [
            QuizQuestion(
              id: 'default-q1',
              text:
                  'Qual a importância da realidade aumentada no ensino médico?',
              options: [
                QuizOption(
                    text: 'Não tem relevância para o ensino médico',
                    isCorrect: false),
                QuizOption(
                    text: 'Apenas para entretenimento dos estudantes',
                    isCorrect: false),
                QuizOption(
                    text:
                        'Permite visualização tridimensional de estruturas complexas',
                    isCorrect: true),
                QuizOption(
                    text: 'Substitui completamente estudos em cadáveres',
                    isCorrect: false),
              ],
              explanation:
                  'A realidade aumentada permite a visualização de estruturas anatômicas complexas em 3D, facilitando a compreensão espacial e funcional.',
            ),
            QuizQuestion(
              id: 'default-q2',
              text: 'Como a tecnologia pode melhorar o aprendizado cirúrgico?',
              options: [
                QuizOption(text: 'Substituindo professores', isCorrect: false),
                QuizOption(
                    text: 'Eliminando a necessidade de práticas reais',
                    isCorrect: false),
                QuizOption(
                    text:
                        'Permitindo repetição e prática sem riscos aos pacientes',
                    isCorrect: true),
                QuizOption(
                    text: 'Reduzindo o tempo de estudo necessário',
                    isCorrect: false),
              ],
              explanation:
                  'A tecnologia educacional permite que estudantes pratiquem procedimentos repetidamente em ambientes seguros antes de atender pacientes reais.',
            ),
          ],
        );
    }
  }
}

class QuizQuestion {
  final String id;
  final String text;
  final List<QuizOption> options;
  final String explanation; // Explanation of the correct answer
  int? selectedOptionIndex; // Index of the user's selected option

  QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.explanation,
    this.selectedOptionIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      text: json['text'],
      options:
          (json['options'] as List).map((o) => QuizOption.fromJson(o)).toList(),
      explanation: json['explanation'],
      selectedOptionIndex: json['selectedOptionIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options.map((o) => o.toJson()).toList(),
      'explanation': explanation,
      'selectedOptionIndex': selectedOptionIndex,
    };
  }

  // Check if the selected answer is correct
  bool isCorrect() {
    if (selectedOptionIndex == null) return false;
    return options[selectedOptionIndex!].isCorrect;
  }

  // Get the correct option
  QuizOption getCorrectOption() {
    return options.firstWhere((option) => option.isCorrect);
  }

  // Reset the selected option
  void reset() {
    selectedOptionIndex = null;
  }
}

class QuizOption {
  final String text;
  final bool isCorrect;

  QuizOption({
    required this.text,
    required this.isCorrect,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      text: json['text'],
      isCorrect: json['isCorrect'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}

class QuizResult {
  final String quizId;
  final String moduleId;
  final int score; // Number of correct answers
  final int totalQuestions;
  final List<QuizQuestionResult> questionResults;
  final DateTime completedDate;

  QuizResult({
    required this.quizId,
    required this.moduleId,
    required this.score,
    required this.totalQuestions,
    required this.questionResults,
    required this.completedDate,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      quizId: json['quizId'],
      moduleId: json['moduleId'],
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      questionResults: (json['questionResults'] as List)
          .map((q) => QuizQuestionResult.fromJson(q))
          .toList(),
      completedDate: DateTime.parse(json['completedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'moduleId': moduleId,
      'score': score,
      'totalQuestions': totalQuestions,
      'questionResults': questionResults.map((q) => q.toJson()).toList(),
      'completedDate': completedDate.toIso8601String(),
    };
  }

  // Calculate percentage score
  double get percentageScore {
    return (score / totalQuestions) * 100;
  }

  // Check if the user passed the quiz (usually 70% or above)
  bool isPassed(int passingScore) {
    return percentageScore >= passingScore;
  }
}

class QuizQuestionResult {
  final String questionId;
  final int selectedOptionIndex;
  final bool isCorrect;

  QuizQuestionResult({
    required this.questionId,
    required this.selectedOptionIndex,
    required this.isCorrect,
  });

  factory QuizQuestionResult.fromJson(Map<String, dynamic> json) {
    return QuizQuestionResult(
      questionId: json['questionId'],
      selectedOptionIndex: json['selectedOptionIndex'],
      isCorrect: json['isCorrect'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedOptionIndex': selectedOptionIndex,
      'isCorrect': isCorrect,
    };
  }
}
