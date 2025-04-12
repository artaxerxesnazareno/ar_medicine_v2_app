import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Teste {
  final String id;
  final String titulo;
  final String descricao;
  final String conteudoId; // ID of the related content
  final List<Map<String, dynamic>> perguntas;
  final List<int>? respostas; // User's answers (indices)
  final int notaAprovacao; // Minimum percentage to pass
  final bool? concluido; // Whether the test has been completed
  final double? pontuacao; // User's score (percentage)

  Teste({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.conteudoId,
    required this.perguntas,
    this.respostas,
    this.notaAprovacao = 70, // Default passing score is 70%
    this.concluido = false,
    this.pontuacao,
  });

  factory Teste.fromJson(Map<String, dynamic> json) {
    return Teste(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      conteudoId: json['conteudoId'],
      perguntas: List<Map<String, dynamic>>.from(json['perguntas']),
      respostas:
          json['respostas'] != null ? List<int>.from(json['respostas']) : null,
      notaAprovacao: json['notaAprovacao'] ?? 70,
      concluido: json['concluido'] ?? false,
      pontuacao: json['pontuacao'] != null ? json['pontuacao'].toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'conteudoId': conteudoId,
      'perguntas': perguntas,
      'respostas': respostas,
      'notaAprovacao': notaAprovacao,
      'concluido': concluido,
      'pontuacao': pontuacao,
    };
  }

  // Método de cópia com modificações
  Teste copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? conteudoId,
    List<Map<String, dynamic>>? perguntas,
    List<int>? respostas,
    int? notaAprovacao,
    bool? concluido,
    double? pontuacao,
  }) {
    return Teste(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      conteudoId: conteudoId ?? this.conteudoId,
      perguntas: perguntas ?? this.perguntas,
      respostas: respostas ?? this.respostas,
      notaAprovacao: notaAprovacao ?? this.notaAprovacao,
      concluido: concluido ?? this.concluido,
      pontuacao: pontuacao ?? this.pontuacao,
    );
  }

  // Calculate the total possible score
  int get totalPerguntas => perguntas.length;

  // Take the test and record answers
  Future<Score> realizarTeste(String userId, List<int> respostasUsuario) async {
    if (respostasUsuario.length != perguntas.length) {
      throw Exception('Number of answers does not match number of questions');
    }

    // Calculate score
    int acertos = 0;
    for (int i = 0; i < perguntas.length; i++) {
      if (respostasUsuario[i] == perguntas[i]['respostaCorreta']) {
        acertos++;
      }
    }

    final pontuacao = (acertos / perguntas.length * 100).round();
    final aprovado = pontuacao >= notaAprovacao;

    // Create score object
    final score = Score(
      testeId: id,
      userId: userId,
      pontuacao: pontuacao,
      aprovado: aprovado,
      respostas: respostasUsuario,
      data: DateTime.now(),
    );

    // Save score to storage
    await score.salvar();

    return score;
  }

  // Get a copy of this test with user's answers (for review)
  Teste copiaTeste(List<int> respostasUsuario) {
    return Teste(
      id: id,
      titulo: titulo,
      descricao: descricao,
      conteudoId: conteudoId,
      perguntas: perguntas,
      respostas: respostasUsuario,
      notaAprovacao: notaAprovacao,
      concluido: concluido,
      pontuacao: pontuacao,
    );
  }
}

class Score {
  final String testeId;
  final String userId;
  final int pontuacao;
  final bool aprovado;
  final List<int> respostas;
  final DateTime data;

  Score({
    required this.testeId,
    required this.userId,
    required this.pontuacao,
    required this.aprovado,
    required this.respostas,
    required this.data,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      testeId: json['testeId'],
      userId: json['userId'],
      pontuacao: json['pontuacao'],
      aprovado: json['aprovado'],
      respostas: List<int>.from(json['respostas']),
      data: DateTime.parse(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testeId': testeId,
      'userId': userId,
      'pontuacao': pontuacao,
      'aprovado': aprovado,
      'respostas': respostas,
      'data': data.toIso8601String(),
    };
  }

  // Save score to storage
  Future<void> salvar() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing scores
      final scoresJson = prefs.getString('scores_$userId') ?? '[]';
      final List<dynamic> scores = jsonDecode(scoresJson);

      // Add new score
      scores.add(toJson());

      // Save updated scores
      await prefs.setString('scores_$userId', jsonEncode(scores));
    } catch (e) {
      print('Error saving score: $e');
    }
  }

  // Export score (for example, to share or print)
  String exportarScore() {
    final formattedDate = '${data.day}/${data.month}/${data.year}';
    return 'Teste: $testeId\nPontuau00e7u00e3o: $pontuacao%\nResultado: ${aprovado ? "Aprovado" : "Reprovado"}\nData: $formattedDate';
  }

  // Get all scores for a user
  static Future<List<Score>> getScoresByUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final scoresJson = prefs.getString('scores_$userId') ?? '[]';
      final List<dynamic> scores = jsonDecode(scoresJson);

      return scores.map((s) => Score.fromJson(s)).toList();
    } catch (e) {
      print('Error getting scores: $e');
      return [];
    }
  }

  // Get user's highest score for a specific test
  static Future<Score?> getHighestScore(String userId, String testeId) async {
    try {
      final scores = await getScoresByUser(userId);
      final testScores = scores.where((s) => s.testeId == testeId).toList();

      if (testScores.isEmpty) {
        return null;
      }

      testScores.sort((a, b) => b.pontuacao.compareTo(a.pontuacao));
      return testScores.first;
    } catch (e) {
      print('Error getting highest score: $e');
      return null;
    }
  }
}
