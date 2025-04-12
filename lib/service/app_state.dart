import 'package:flutter/foundation.dart';
import 'package:ar_demo_ti/models/jornada_model.dart';
import 'package:ar_demo_ti/models/conteudo_model.dart';
import 'package:ar_demo_ti/models/teste_model.dart';

/// Classe responsável por gerenciar o estado global da aplicação
///
/// Este provider contém todos os dados relacionados ao usuário,
/// suas jornadas e progresso no aplicativo
class AppState extends ChangeNotifier {
  bool isLoading = false;
  
  // Usuário atual
  dynamic currentUser; // Substitua por sua classe de usuário
  String? userId;
  
  // Jornadas
  List<Jornada> _jornadasUsuario = [];
  List<Jornada> get jornadasUsuario => _jornadasUsuario;
  
  // Estatísticas
  int _totalTestesConcluidos = 0;
  int get totalTestesConcluidos => _totalTestesConcluidos;
  
  double _pontuacaoMedia = 0.0;
  double get pontuacaoMedia => _pontuacaoMedia;
  
  // Construtor
  AppState() {
    // Inicializar dados do usuário, como carregar do cache
    _carregarDados();
  }
  
  // Métodos para gerenciar dados
  Future<void> _carregarDados() async {
    isLoading = true;
    notifyListeners();
    
    try {
      // Implementar lógica para carregar dados do usuário
      // ex: _jornadasUsuario = await _storageService.getJornadas();
      
      // Cálculos para estatísticas
      _calcularEstatisticas();
    } catch (e) {
      // Tratamento de erro
      debugPrint('Erro ao carregar dados: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  void refreshData() {
    _carregarDados();
  }
  
  void _calcularEstatisticas() {
    // Calcular total de testes concluídos
    _totalTestesConcluidos = 0;
    double totalPontuacao = 0;
    int totalTestes = 0;
    
    for (var jornada in _jornadasUsuario) {
      for (var teste in jornada.testes) {
        if (teste.concluido == true) {
          _totalTestesConcluidos++;
          if (teste.pontuacao != null) {
            totalPontuacao += teste.pontuacao!;
            totalTestes++;
          }
        }
      }
    }
    
    // Calcular pontuação média
    _pontuacaoMedia = totalTestes > 0 ? totalPontuacao / totalTestes * 100 : 0;
  }
  
  // Iniciar uma jornada
  void iniciarJornada(String jornadaId) {
    final index = _jornadasUsuario.indexWhere((j) => j.id == jornadaId);
    if (index >= 0) {
      _jornadasUsuario[index] = _jornadasUsuario[index].copyWith(iniciada: true);
      
      // Aqui você implementaria a persistência
      // ex: _storageService.salvarProgresso(jornadaId, true);
      
      notifyListeners();
    }
  }
  
  // Marcar conteúdo como visualizado
  void marcarConteudoVisualizado(String jornadaId, String conteudoId) {
    final jornadaIndex = _jornadasUsuario.indexWhere((j) => j.id == jornadaId);
    
    if (jornadaIndex >= 0) {
      final jornada = _jornadasUsuario[jornadaIndex];
      final conteudoIndex = jornada.conteudos.indexWhere((c) => c.id == conteudoId);
      
      if (conteudoIndex >= 0) {
        // Atualizar o conteúdo para visualizado
        final conteudosAtualizados = List<Conteudo>.from(jornada.conteudos);
        conteudosAtualizados[conteudoIndex] = 
            conteudosAtualizados[conteudoIndex].copyWith(visualizado: true);
        
        // Atualizar a jornada com os novos conteúdos
        _jornadasUsuario[jornadaIndex] = jornada.copyWith(
          conteudos: conteudosAtualizados,
          // Recalcular progresso
          progresso: conteudosAtualizados.where((c) => c.visualizado).length / 
                    conteudosAtualizados.length
        );
        
        // Persistir mudanças
        // ex: _storageService.atualizarJornada(_jornadasUsuario[jornadaIndex]);
        
        notifyListeners();
      }
    }
  }
  
  // Método para atualizar teste concluído
  void atualizarTesteConcluido(String testeId, double pontuacao) {
    for (var i = 0; i < _jornadasUsuario.length; i++) {
      final jornada = _jornadasUsuario[i];
      final testeIndex = jornada.testes.indexWhere((t) => t.id == testeId);
      
      if (testeIndex >= 0) {
        // Atualizar o teste
        final testesAtualizados = List<Teste>.from(jornada.testes);
        testesAtualizados[testeIndex] = testesAtualizados[testeIndex].copyWith(
          concluido: true,
          pontuacao: pontuacao
        );
        
        // Atualizar a jornada
        _jornadasUsuario[i] = jornada.copyWith(testes: testesAtualizados);
        
        // Recalcular estatísticas
        _calcularEstatisticas();
        
        // Persistir mudanças
        // ex: _storageService.atualizarTeste(testeId, pontuacao);
        
        notifyListeners();
        break;
      }
    }
  }
} 