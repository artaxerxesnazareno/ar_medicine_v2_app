import 'package:ar_demo_ti/models/jornada_model.dart';
import 'package:ar_demo_ti/models/teste_model.dart';
import 'package:ar_demo_ti/models/user_model.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String? _userId;
  User? _currentUser;
  List<Jornada> _jornadasUsuario = [];
  int _totalTestesConcluidos = 0;
  double _pontuacaoMedia = 0.0;
  bool _isLoading = true;

  String? get userId => _userId;
  User? get currentUser => _currentUser;
  List<Jornada> get jornadasUsuario => _jornadasUsuario;
  int get totalTestesConcluidos => _totalTestesConcluidos;
  double get pontuacaoMedia => _pontuacaoMedia;
  bool get isLoading => _isLoading;

  AppState() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _isLoading = true;
    notifyListeners();

    // Get current user (if any)
    _currentUser = await User.getCurrentUser();
    if (_currentUser != null) {
      _userId = _currentUser!.email;
      await _carregarProgressoUsuario();
    } else {
      // For demo purposes, create a temporary user
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _jornadasUsuario = Jornada.getJornadasDisponiveis();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _carregarProgressoUsuario() async {
    if (_userId == null) return;

    // Get all available journeys
    final jornadasDisponiveis = Jornada.getJornadasDisponiveis();
    _jornadasUsuario = [];

    // For each journey, try to get user's progress
    for (final jornada in jornadasDisponiveis) {
      final jornadaUsuario = await Jornada.retomarJornada(_userId!, jornada.id);
      if (jornadaUsuario != null) {
        _jornadasUsuario.add(jornadaUsuario);
      } else {
        _jornadasUsuario.add(jornada);
      }
    }

    // Calculate test statistics
    final scores = await Score.getScoresByUser(_userId!);
    _totalTestesConcluidos = scores.length;

    if (scores.isNotEmpty) {
      int totalPontuacao =
          scores.fold(0, (sum, score) => sum + score.pontuacao);
      _pontuacaoMedia = totalPontuacao / scores.length;
    }

    notifyListeners();
  }

  // Login user
  Future<bool> login(String email, String senha) async {
    _isLoading = true;
    notifyListeners();

    final user = await User.autenticar(email, senha);
    if (user != null) {
      _currentUser = user;
      _userId = user.email;
      await _carregarProgressoUsuario();

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Register new user
  Future<bool> registrar(String nome, String email, String senha) async {
    _isLoading = true;
    notifyListeners();

    final user = User(nome: nome, email: email, senha: senha);
    final success = await User.criarConta(user);

    if (success) {
      _currentUser = user;
      _userId = user.email;
      await _carregarProgressoUsuario();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  // Logout
  Future<void> logout() async {
    await User.logout();
    _currentUser = null;
    _userId = null;
    _jornadasUsuario = Jornada.getJornadasDisponiveis();
    _totalTestesConcluidos = 0;
    _pontuacaoMedia = 0.0;
    notifyListeners();
  }

  // Start a journey
  Future<void> iniciarJornada(String jornadaId) async {
    if (_userId == null) return;

    final index = _jornadasUsuario.indexWhere((j) => j.id == jornadaId);
    if (index >= 0) {
      await _jornadasUsuario[index].iniciarJornada(_userId!);
      notifyListeners();
    }
  }

  // Update journey progress
  Future<void> atualizarProgressoJornada(
      String jornadaId, double progresso) async {
    if (_userId == null) return;

    final index = _jornadasUsuario.indexWhere((j) => j.id == jornadaId);
    if (index >= 0) {
      await _jornadasUsuario[index].atualizarProgresso(_userId!, progresso);
      notifyListeners();
    }
  }

  // Mark content as viewed
  Future<void> marcarConteudoVisualizado(
      String jornadaId, String conteudoId) async {
    if (_userId == null) return;

    final jornada = _jornadasUsuario.firstWhere(
      (j) => j.id == jornadaId,
      orElse: () =>
          Jornada.getJornadasDisponiveis().firstWhere((j) => j.id == jornadaId),
    );

    final conteudoIndex =
        jornada.conteudos.indexWhere((c) => c.id == conteudoId);
    if (conteudoIndex >= 0) {
      // Find the journey in user's journeys and update it
      final jornadaIndex =
          _jornadasUsuario.indexWhere((j) => j.id == jornadaId);
      if (jornadaIndex >= 0) {
        _jornadasUsuario[jornadaIndex].conteudos[conteudoIndex].visualizar();

        // Update progress
        final totalConteudos = jornada.conteudos.length;
        final conteudosVisualizados =
            jornada.conteudos.where((c) => c.visualizado).length;
        final progresso = conteudosVisualizados / totalConteudos;

        await atualizarProgressoJornada(jornadaId, progresso);
        notifyListeners();
      }
    }
  }

  // Refresh all user data
  Future<void> refreshData() async {
    if (_userId != null) {
      await _carregarProgressoUsuario();
    }
  }
}
