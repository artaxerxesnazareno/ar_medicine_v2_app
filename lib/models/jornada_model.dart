import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'conteudo_model.dart';
import 'teste_model.dart';
import 'user_model.dart';

class Jornada {
  final String id;
  final String titulo;
  final String descricao;
  final String imageKeyword;
  final String category;
  final List<Conteudo> conteudos;
  final List<Teste> testes;
  final int tempoEstimado; // in minutes
  bool iniciada;
  double progresso;

  Jornada({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.imageKeyword,
    required this.category,
    required this.conteudos,
    required this.testes,
    required this.tempoEstimado,
    this.iniciada = false,
    this.progresso = 0.0,
  });

  factory Jornada.fromJson(Map<String, dynamic> json) {
    return Jornada(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      imageKeyword: json['imageKeyword'],
      category: json['category'],
      conteudos: (json['conteudos'] as List)
          .map((conteudo) => Conteudo.fromJson(conteudo))
          .toList(),
      testes: (json['testes'] as List)
          .map((teste) => Teste.fromJson(teste))
          .toList(),
      tempoEstimado: json['tempoEstimado'],
      iniciada: json['iniciada'] ?? false,
      progresso: json['progresso'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'imageKeyword': imageKeyword,
      'category': category,
      'conteudos': conteudos.map((conteudo) => conteudo.toJson()).toList(),
      'testes': testes.map((teste) => teste.toJson()).toList(),
      'tempoEstimado': tempoEstimado,
      'iniciada': iniciada,
      'progresso': progresso,
    };
  }

  // Método de cópia com modificações
  Jornada copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? imageKeyword,
    String? category,
    List<Conteudo>? conteudos,
    List<Teste>? testes,
    int? tempoEstimado,
    bool? iniciada,
    double? progresso,
  }) {
    return Jornada(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      imageKeyword: imageKeyword ?? this.imageKeyword,
      category: category ?? this.category,
      conteudos: conteudos ?? this.conteudos,
      testes: testes ?? this.testes,
      tempoEstimado: tempoEstimado ?? this.tempoEstimado,
      iniciada: iniciada ?? this.iniciada,
      progresso: progresso ?? this.progresso,
    );
  }

  // Start a journey
  Future<bool> iniciarJornada(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Mark journey as started
      iniciada = true;
      progresso = 0.0;

      // Save journey progress
      final key = 'jornada_${userId}_${id}';
      await prefs.setString(key, jsonEncode(toJson()));

      return true;
    } catch (e) {
      print('Error starting journey: $e');
      return false;
    }
  }

  // Resume a journey
  static Future<Jornada?> retomarJornada(
      String userId, String jornadaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get journey progress
      final key = 'jornada_${userId}_${jornadaId}';
      final jornadaJson = prefs.getString(key);

      if (jornadaJson == null) {
        // Journey not started yet
        final baseJornada = getJornadaById(jornadaId);
        if (baseJornada != null) {
          await baseJornada.iniciarJornada(userId);
          return baseJornada;
        }
        return null;
      }

      return Jornada.fromJson(jsonDecode(jornadaJson));
    } catch (e) {
      print('Error resuming journey: $e');
      return null;
    }
  }

  // Update journey progress
  Future<bool> atualizarProgresso(String userId, double novoProgresso) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Update progress
      progresso = novoProgresso;

      // Save updated journey
      final key = 'jornada_${userId}_${id}';
      await prefs.setString(key, jsonEncode(toJson()));

      return true;
    } catch (e) {
      print('Error updating journey progress: $e');
      return false;
    }
  }

  // Get journey by ID
  static Jornada? getJornadaById(String jornadaId) {
    final jornadas = getJornadasDisponiveis();
    try {
      return jornadas.firstWhere((jornada) => jornada.id == jornadaId);
    } catch (e) {
      return null;
    }
  }

  // Get all available journeys
  static List<Jornada> getJornadasDisponiveis() {
    return [
      Jornada(
        id: '1',
        titulo: 'Anatomia Abdominal',
        descricao:
            'Estude as estruturas anatômicas do abdômen e sua relação com procedimentos cirúrgicos.',
        imageKeyword: 'Abdominal Anatomy',
        category: 'science',
        conteudos: [
          Conteudo(
            id: '1-1',
            titulo: 'Visão Geral da Anatomia Abdominal',
            tipo: 'ar',
            dados: 'abdominal_wall',
            descricao: 'Compreenda a estrutura básica da cavidade abdominal.',
          ),
          Conteudo(
            id: '1-2',
            titulo: 'Órgãos Abdominais',
            tipo: 'ar',
            dados: 'abdominal_organs',
            descricao:
                'Estude o posicionamento e função dos órgãos na cavidade abdominal.',
          ),
        ],
        testes: [
          Teste(
            id: 'teste-1-1',
            titulo: 'Quiz: Anatomia da Parede Abdominal',
            descricao:
                'Teste seus conhecimentos sobre as camadas e estruturas da parede abdominal.',
            conteudoId: '1-1',
            perguntas: [
              {
                'texto':
                    'Qual das seguintes camadas NÃO faz parte da parede abdominal?',
                'opcoes': [
                  'Pele',
                  'Fáscia superficial',
                  'Peritônio',
                  'Epitélio alveolar',
                ],
                'respostaCorreta': 3,
                'explicacao':
                    'O epitélio alveolar é encontrado nos pulmões, não na parede abdominal. A parede abdominal consiste em pele, fáscia superficial, músculos, fáscia transversal e peritônio.'
              },
              {
                'texto':
                    'Qual músculo forma a linha alba na parede abdominal anterior?',
                'opcoes': [
                  'Reto abdominal',
                  'Transverso do abdômen',
                  'Oblíquo externo',
                  'É uma estrutura tendinosa, não muscular',
                ],
                'respostaCorreta': 3,
                'explicacao':
                    'A linha alba é uma estrutura tendinosa formada pela fusão das aponeuroses dos músculos abdominais na linha média.'
              },
              {
                'texto':
                    'Qual estrutura anatômica separa a cavidade abdominal da torácica?',
                'opcoes': [
                  'Diafragma',
                  'Peritônio',
                  'Fáscia transversal',
                  'Músculos intercostais',
                ],
                'respostaCorreta': 0,
                'explicacao':
                    'O diafragma é o músculo que separa a cavidade torácica da abdominal e é essencial para a respiração.'
              },
            ],
          ),
          Teste(
            id: 'teste-1-2',
            titulo: 'Quiz: Órgãos Abdominais',
            descricao:
                'Teste seus conhecimentos sobre os órgãos na cavidade abdominal.',
            conteudoId: '1-2',
            perguntas: [
              {
                'texto':
                    'Qual das seguintes estruturas está localizada no quadrante inferior direito do abdômen?',
                'opcoes': [
                  'Baço',
                  'Apêndice',
                  'Estômago',
                  'Rim esquerdo',
                ],
                'respostaCorreta': 1,
                'explicacao':
                    'O apêndice vermiforme está localizado no quadrante inferior direito do abdômen, conectado ao ceco do intestino grosso.'
              },
              {
                'texto': 'Qual é a principal função do peritônio?',
                'opcoes': [
                  'Fornecer suporte estrutural para os músculos abdominais',
                  'Secretar enzimas digestivas',
                  'Reduzir a fricção entre órgãos abdominais',
                  'Armazenar gordura corporal',
                ],
                'respostaCorreta': 2,
                'explicacao':
                    'O peritônio é uma membrana serosa que reveste a cavidade abdominal e cobre a maioria dos órgãos abdominais. Sua principal função é reduzir a fricção entre órgãos e facilitar o movimento.'
              },
            ],
          ),
        ],
        tempoEstimado: 60,
      ),
      Jornada(
        id: '2',
        titulo: 'Técnicas de Sutura',
        descricao:
            'Aprenda diferentes técnicas de sutura utilizadas em procedimentos cirúrgicos.',
        imageKeyword: 'Surgical Sutures',
        category: 'health',
        conteudos: [
          Conteudo(
            id: '2-1',
            titulo: 'Fundamentos da Sutura',
            tipo: 'ar',
            dados: 'suture_types',
            descricao: 'Compreenda os princípios básicos da sutura cirúrgica.',
          ),
          Conteudo(
            id: '2-2',
            titulo: 'Técnicas Avançadas',
            tipo: 'ar',
            dados: 'advanced_sutures',
            descricao:
                'Aprenda técnicas avançadas para diferentes contextos cirúrgicos.',
          ),
        ],
        testes: [
          Teste(
            id: 'teste-2-1',
            titulo: 'Quiz: Fundamentos da Sutura',
            descricao:
                'Teste seus conhecimentos sobre os princípios básicos e materiais de sutura.',
            conteudoId: '2-1',
            perguntas: [
              {
                'texto':
                    'Qual das seguintes NÃO é uma classificação de material de sutura?',
                'opcoes': [
                  'Absorvível',
                  'Não-absorvível',
                  'Monofilamentar',
                  'Extracelular',
                ],
                'respostaCorreta': 3,
                'explicacao':
                    'Os materiais de sutura são classificados como absorvíveis ou não-absorvíveis, e como monofilamentares ou multifilamentares. "Extracelular" não é uma classificação de material de sutura.'
              },
              {
                'texto':
                    'Qual tipo de sutura é mais adequado para tecidos que precisam de suporte por longos períodos?',
                'opcoes': [
                  'Catgut simples',
                  'Poliglactina 910 (Vicryl)',
                  'Seda',
                  'Poliglecaprone 25 (Monocryl)',
                ],
                'respostaCorreta': 2,
                'explicacao':
                    'A seda é um material não-absorvível que fornece suporte ao tecido por longos períodos, tornando-a adequada para tecidos que precisam de suporte prolongado.'
              },
            ],
          ),
        ],
        tempoEstimado: 75,
      ),
      Jornada(
        id: '3',
        titulo: 'Instrumentação Cirúrgica',
        descricao:
            'Conheça os principais instrumentos utilizados em cirurgias gerais.',
        imageKeyword: 'Surgical Instruments',
        category: 'health',
        conteudos: [
          Conteudo(
            id: '3-1',
            titulo: 'Instrumentos Básicos',
            tipo: 'ar',
            dados: 'basic_instruments',
            descricao:
                'Identifique e compreenda o uso dos instrumentos cirúrgicos fundamentais.',
          ),
          Conteudo(
            id: '3-2',
            titulo: 'Instrumentos Especializados',
            tipo: 'ar',
            dados: 'specialized_instruments',
            descricao:
                'Conheça instrumentos específicos para diferentes especialidades cirúrgicas.',
          ),
        ],
        testes: [
          Teste(
            id: 'teste-3-1',
            titulo: 'Quiz: Instrumentação Cirúrgica Básica',
            descricao:
                'Teste seus conhecimentos sobre instrumentos cirúrgicos fundamentais.',
            conteudoId: '3-1',
            perguntas: [
              {
                'texto':
                    'Qual instrumento é utilizado primariamente para segurar tecidos durante a dissecção?',
                'opcoes': [
                  'Pinça Kelly',
                  'Pinça Adson',
                  'Porta-agulhas',
                  'Tesoura Metzenbaum',
                ],
                'respostaCorreta': 1,
                'explicacao':
                    'A pinça Adson é uma pinça de dissecção utilizada para segurar delicadamente os tecidos durante procedimentos cirúrgicos.'
              },
              {
                'texto':
                    'Qual instrumento é utilizado para hemostasia de vasos de pequeno e médio calibre?',
                'opcoes': [
                  'Pinça Kocher',
                  'Pinça Babcock',
                  'Pinça Kelly',
                  'Afastador Farabeuf',
                ],
                'respostaCorreta': 2,
                'explicacao':
                    'A pinça Kelly é uma pinça hemostática utilizada para clipar e ocluir vasos sanguíneos de pequeno e médio calibre durante procedimentos cirúrgicos.'
              },
            ],
          ),
        ],
        tempoEstimado: 45,
      ),
    ];
  }
}
