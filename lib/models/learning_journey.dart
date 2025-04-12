class LearningJourney {
  final String id;
  final String title;
  final String description;
  final String imageKeyword;
  final String category;
  final List<LearningModule> modules;
  final int totalQuizzes;
  final int estimatedCompletionTime; // in minutes

  LearningJourney({
    required this.id,
    required this.title,
    required this.description,
    required this.imageKeyword,
    required this.category,
    required this.modules,
    required this.totalQuizzes,
    required this.estimatedCompletionTime,
  });

  factory LearningJourney.fromJson(Map<String, dynamic> json) {
    return LearningJourney(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageKeyword: json['imageKeyword'],
      category: json['category'],
      modules: (json['modules'] as List)
          .map((module) => LearningModule.fromJson(module))
          .toList(),
      totalQuizzes: json['totalQuizzes'],
      estimatedCompletionTime: json['estimatedCompletionTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageKeyword': imageKeyword,
      'category': category,
      'modules': modules.map((module) => module.toJson()).toList(),
      'totalQuizzes': totalQuizzes,
      'estimatedCompletionTime': estimatedCompletionTime,
    };
  }

  // Mock data for sample journeys
  static List<LearningJourney> getSampleJourneys() {
    return [
      LearningJourney(
        id: '1',
        title: 'Anatomia Abdominal',
        description:
            'Estude as estruturas anatômicas do abdômen e sua relação com procedimentos cirúrgicos.',
        imageKeyword: 'Abdominal Anatomy',
        category: 'science',
        modules: [
          LearningModule(
            id: '1-1',
            title: 'Visão Geral da Anatomia Abdominal',
            description: 'Compreenda a estrutura básica da cavidade abdominal.',
            arContent: ArContent(
              id: '1-1-ar',
              title: 'Camadas da Parede Abdominal',
              description:
                  'Explore as diferentes camadas da parede abdominal em 3D.',
              arModelName: 'abdominal_wall',
            ),
            hasQuiz: true,
          ),
          LearningModule(
            id: '1-2',
            title: 'Órgãos Abdominais',
            description:
                'Estude o posicionamento e função dos órgãos na cavidade abdominal.',
            arContent: ArContent(
              id: '1-2-ar',
              title: 'Disposição dos Órgãos Abdominais',
              description: 'Visualize o posicionamento dos órgãos em 3D.',
              arModelName: 'abdominal_organs',
            ),
            hasQuiz: true,
          ),
        ],
        totalQuizzes: 2,
        estimatedCompletionTime: 60,
      ),
      LearningJourney(
        id: '2',
        title: 'Técnicas de Sutura',
        description:
            'Aprenda diferentes técnicas de sutura utilizadas em procedimentos cirúrgicos.',
        imageKeyword: 'Surgical Sutures',
        category: 'health',
        modules: [
          LearningModule(
            id: '2-1',
            title: 'Fundamentos da Sutura',
            description:
                'Compreenda os princípios básicos da sutura cirúrgica.',
            arContent: ArContent(
              id: '2-1-ar',
              title: 'Tipos de Suturas',
              description:
                  'Visualize os diferentes tipos de materiais e pontos de sutura em 3D.',
              arModelName: 'suture_types',
            ),
            hasQuiz: true,
          ),
          LearningModule(
            id: '2-2',
            title: 'Técnicas Avançadas',
            description:
                'Aprenda técnicas avançadas para diferentes contextos cirúrgicos.',
            arContent: ArContent(
              id: '2-2-ar',
              title: 'Sutura em Diferentes Tecidos',
              description:
                  'Visualize técnicas de sutura em diferentes tecidos e órgãos.',
              arModelName: 'advanced_sutures',
            ),
            hasQuiz: true,
          ),
        ],
        totalQuizzes: 2,
        estimatedCompletionTime: 75,
      ),
      LearningJourney(
        id: '3',
        title: 'Instrumentação Cirúrgica',
        description:
            'Conheça os principais instrumentos utilizados em cirurgias gerais.',
        imageKeyword: 'Surgical Instruments',
        category: 'health',
        modules: [
          LearningModule(
            id: '3-1',
            title: 'Instrumentos Básicos',
            description:
                'Identifique e compreenda o uso dos instrumentos cirúrgicos fundamentais.',
            arContent: ArContent(
              id: '3-1-ar',
              title: 'Kit de Instrumentos Básicos',
              description:
                  'Visualize e interaja com instrumentos cirúrgicos básicos em 3D.',
              arModelName: 'basic_instruments',
            ),
            hasQuiz: true,
          ),
          LearningModule(
            id: '3-2',
            title: 'Instrumentos Especializados',
            description:
                'Conheça instrumentos específicos para diferentes especialidades cirúrgicas.',
            arContent: ArContent(
              id: '3-2-ar',
              title: 'Instrumentos Especializados',
              description:
                  'Explore instrumentos cirúrgicos especializados em 3D.',
              arModelName: 'specialized_instruments',
            ),
            hasQuiz: true,
          ),
        ],
        totalQuizzes: 2,
        estimatedCompletionTime: 45,
      ),
    ];
  }
}

class LearningModule {
  final String id;
  final String title;
  final String description;
  final ArContent arContent;
  final bool hasQuiz;
  bool isCompleted;

  LearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.arContent,
    required this.hasQuiz,
    this.isCompleted = false,
  });

  factory LearningModule.fromJson(Map<String, dynamic> json) {
    return LearningModule(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      arContent: ArContent.fromJson(json['arContent']),
      hasQuiz: json['hasQuiz'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'arContent': arContent.toJson(),
      'hasQuiz': hasQuiz,
      'isCompleted': isCompleted,
    };
  }
}

class ArContent {
  final String id;
  final String title;
  final String description;
  final String arModelName; // Name of the AR model file

  ArContent({
    required this.id,
    required this.title,
    required this.description,
    required this.arModelName,
  });

  factory ArContent.fromJson(Map<String, dynamic> json) {
    return ArContent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      arModelName: json['arModelName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'arModelName': arModelName,
    };
  }
}

class UserProgress {
  final String userId;
  final Map<String, JourneyProgress> journeyProgress;

  UserProgress({
    required this.userId,
    required this.journeyProgress,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    Map<String, JourneyProgress> progress = {};
    (json['journeyProgress'] as Map<String, dynamic>).forEach((key, value) {
      progress[key] = JourneyProgress.fromJson(value);
    });

    return UserProgress(
      userId: json['userId'],
      journeyProgress: progress,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> progressMap = {};
    journeyProgress.forEach((key, value) {
      progressMap[key] = value.toJson();
    });

    return {
      'userId': userId,
      'journeyProgress': progressMap,
    };
  }

  // Create a new user progress
  factory UserProgress.createNew(String userId) {
    return UserProgress(
      userId: userId,
      journeyProgress: {},
    );
  }
}

class JourneyProgress {
  final String journeyId;
  final Map<String, bool> completedModules;
  final Map<String, int> quizScores; // module ID -> score
  DateTime lastAccessedDate;

  JourneyProgress({
    required this.journeyId,
    required this.completedModules,
    required this.quizScores,
    required this.lastAccessedDate,
  });

  factory JourneyProgress.fromJson(Map<String, dynamic> json) {
    Map<String, bool> modules = {};
    (json['completedModules'] as Map<String, dynamic>).forEach((key, value) {
      modules[key] = value as bool;
    });

    Map<String, int> scores = {};
    (json['quizScores'] as Map<String, dynamic>).forEach((key, value) {
      scores[key] = value as int;
    });

    return JourneyProgress(
      journeyId: json['journeyId'],
      completedModules: modules,
      quizScores: scores,
      lastAccessedDate: DateTime.parse(json['lastAccessedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'journeyId': journeyId,
      'completedModules': completedModules,
      'quizScores': quizScores,
      'lastAccessedDate': lastAccessedDate.toIso8601String(),
    };
  }

  // Create a new journey progress
  factory JourneyProgress.createNew(String journeyId) {
    return JourneyProgress(
      journeyId: journeyId,
      completedModules: {},
      quizScores: {},
      lastAccessedDate: DateTime.now(),
    );
  }

  // Calculate completion percentage
  double getCompletionPercentage(int totalModules) {
    if (totalModules == 0) return 0.0;
    return completedModules.values.where((v) => v).length / totalModules * 100;
  }

  // Calculate average quiz score
  double getAverageQuizScore() {
    if (quizScores.isEmpty) return 0.0;
    int total = quizScores.values.reduce((a, b) => a + b);
    return total / quizScores.length;
  }
}
