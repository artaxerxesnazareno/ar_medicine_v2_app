import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'conteudo_model.dart';
import 'teste_model.dart';

class Jornada {
  final String id;
  final String titulo;
  final String descricao;
  final String imageUrl;
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
    required this.imageUrl,
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
      imageUrl: json['imageKeyword'],
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
      'imageKeyword': imageUrl,
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
      imageUrl: imageKeyword ?? this.imageUrl,
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
        titulo: 'Anatomia do Coração',
        descricao:
            'Estude a estrutura e funcionamento do coração humano, incluindo suas câmaras, válvulas e sistema de condução.',
        imageUrl:
            'https://media.sketchfab.com/models/3f8072336ce94d18b3d0d055a1ece089/thumbnails/021a0c163a16426b8b4d2c4244e8386d/350bc8326661464fa1b3d4e64d250d85.jpeg',
        category: 'science',
        conteudos: [
          Conteudo(
            id: '1-1',
            titulo: 'Estrutura do Coração',
            tipo: 'ar',
            dados: 'coracao',
            descricao:
                'Visualize a anatomia externa e interna do coração em 3D.',
          ),
          Conteudo(
            id: '1-2',
            titulo: 'Sistema de Condução Cardíaca',
            tipo: 'ar',
            dados: 'coracao',
            descricao:
                'Compreenda como os impulsos elétricos se propagam pelo coração.',
          ),
        ],
        testes: [
          Teste(
            id: 'teste-1-1',
            titulo: 'Quiz: Anatomia do Coração',
            descricao:
                'Teste seus conhecimentos sobre a estrutura anatômica do coração.',
            conteudoId: '1-1',
            perguntas: [
              {
                'texto':
                    'Qual das seguintes câmaras do coração recebe sangue desoxigenado do corpo?',
                'opcoes': [
                  'Átrio direito',
                  'Átrio esquerdo',
                  'Ventrículo direito',
                  'Ventrículo esquerdo',
                ],
                'respostaCorreta': 0,
                'explicacao':
                    'O átrio direito recebe sangue desoxigenado das veias cavas superior e inferior, proveniente da circulação sistêmica.'
              },
              {
                'texto':
                    'Qual válvula cardíaca separa o átrio esquerdo do ventrículo esquerdo?',
                'opcoes': [
                  'Válvula tricúspide',
                  'Válvula mitral',
                  'Válvula pulmonar',
                  'Válvula aórtica',
                ],
                'respostaCorreta': 1,
                'explicacao':
                    'A válvula mitral (também chamada de bicúspide) separa o átrio esquerdo do ventrículo esquerdo, controlando o fluxo de sangue oxigenado dos pulmões para o ventrículo esquerdo.'
              },
              {
                'texto':
                    'Qual estrutura do coração é responsável por iniciar o impulso elétrico que leva à contração?',
                'opcoes': [
                  'Nodo sinoatrial (SA)',
                  'Nodo atrioventricular (AV)',
                  'Feixe de His',
                  'Fibras de Purkinje',
                ],
                'respostaCorreta': 0,
                'explicacao':
                    'O nodo sinoatrial (SA), também conhecido como marcapasso natural do coração, é responsável por iniciar o impulso elétrico que desencadeia a contração cardíaca.'
              },
            ],
          ),
          Teste(
            id: 'teste-1-2',
            titulo: 'Quiz: Sistema de Condução Cardíaca',
            descricao:
                'Teste seus conhecimentos sobre o sistema de condução elétrica do coração.',
            conteudoId: '1-2',
            perguntas: [
              {
                'texto':
                    'Qual é a sequência correta do sistema de condução cardíaca?',
                'opcoes': [
                  'Nodo SA → Nodo AV → Feixe de His → Fibras de Purkinje',
                  'Nodo AV → Nodo SA → Feixe de His → Fibras de Purkinje',
                  'Feixe de His → Nodo SA → Nodo AV → Fibras de Purkinje',
                  'Fibras de Purkinje → Feixe de His → Nodo AV → Nodo SA',
                ],
                'respostaCorreta': 0,
                'explicacao':
                    'A sequência correta é: Nodo SA (marcapasso) → Nodo AV (atrasa o impulso) → Feixe de His (conduz aos ventrículos) → Fibras de Purkinje (distribuem o impulso pelo miocárdio ventricular).'
              },
              {
                'texto':
                    'Qual é a principal função do nodo atrioventricular (AV)?',
                'opcoes': [
                  'Iniciar o batimento cardíaco',
                  'Atrasar o impulso elétrico entre átrios e ventrículos',
                  'Bombear sangue para a aorta',
                  'Fornecer oxigênio ao miocárdio',
                ],
                'respostaCorreta': 1,
                'explicacao':
                    'O nodo AV atrasa o impulso elétrico por aproximadamente 0,1 segundo, permitindo que os átrios se contraiam e esvaziem seu conteúdo nos ventrículos antes da contração ventricular.'
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
        imageUrl:
            'https://media.post.rvohealth.io/wp-content/uploads/2020/08/6298-woman_physician_holding_a_suture_needle_in-732x549-thumbnail-732x549.jpg',
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
        imageUrl:
            'https://www.virginiamasoninstitute.org/wp-content/uploads/2019/09/Surgical-tools-online-newsletter.jpg',
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
