import 'package:ar_demo_ti/Presentation/ar/ar_view_screen.dart';
import 'package:ar_demo_ti/Presentation/joumey/joumey_card/joumey_card.dart';
import 'package:ar_demo_ti/Presentation/quiz/quiz_screen.dart';
import 'package:ar_demo_ti/Presentation/theme/theme.dart';
import 'package:ar_demo_ti/core/app_3d_models_links.dart';
import 'package:ar_demo_ti/examples/localandwebobjectsexample.dart';
import 'package:ar_demo_ti/main.dart';
import 'package:ar_demo_ti/models/conteudo_model.dart';
import 'package:ar_demo_ti/models/jornada_model.dart';
import 'package:ar_demo_ti/models/teste_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final jornadas = appState.jornadasUsuario;
    final jornadasEmProgresso = jornadas.where((j) => j.iniciada).toList();

    return Scaffold(
      body: SafeArea(
        child: appState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // App Bar Section
                  _buildAppBar(context),

                  // Progress Overview
                  _buildProgressOverview(context),

                  // Tab Bar
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.lightText,
                      unselectedLabelColor: AppColors.darkText,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: AppColors.primaryColor,
                      ),
                      tabs: const [
                        Tab(text: 'Todos'),
                        Tab(text: 'Em Progresso'),
                      ],
                    ),
                  ),

                  // Tab Bar View
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // All Journeys
                        _buildJourneyList(jornadas),

                        // In Progress Journeys
                        _buildJourneyList(jornadasEmProgresso),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final userName = appState.currentUser?.nome ?? 'Estudante';

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olu00e1, $userName',
                style: AppFont.regularBoldDark,
              ),
              const SizedBox(height: 4),
              Text(
                'Continue seu aprendizado',
                style: AppFont.bodyText,
              ),
            ],
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryColor,
            child: Icon(
              Icons.person,
              color: AppColors.lightText,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final jornadasIniciadas =
        appState.jornadasUsuario.where((j) => j.iniciada).length;
    final totalJornadas = appState.jornadasUsuario.length;
    final testesConcluidos = appState.totalTestesConcluidos;
    final pontuacaoMedia = appState.pontuacaoMedia.toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryColor,
            AppColors.secondaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seu Progresso',
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.insights,
                color: AppColors.lightText,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildProgressStat(
                  'Jornadas', '$jornadasIniciadas/$totalJornadas', Icons.route),
              const SizedBox(width: 15),
              _buildProgressStat('Testes', '$testesConcluidos', Icons.quiz),
              const SizedBox(width: 15),
              _buildProgressStat('Nota', '$pontuacaoMedia%', Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.lightText.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.lightText,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.lightText.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyList(List<Jornada> jornadas) {
    if (jornadas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 64,
              color: AppColors.grayShade,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma jornada encontrada',
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore as jornadas disponíveis',
              style: TextStyle(
                color: AppColors.grayShade,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: jornadas.length,
      itemBuilder: (context, index) {
        return JourneyCard(
          jornada: jornadas[index],
          onTap: () => _openJourneyDetails(jornadas[index]),
        );
      },
    );
  }

  void _openJourneyDetails(Jornada jornada) {
    final appState = Provider.of<AppState>(context, listen: false);

    // Mark journey as started if not already
    if (!jornada.iniciada && appState.userId != null) {
      appState.iniciarJornada(jornada.id);
    }

    // Show journey details
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildJourneyDetailsSheet(jornada),
    );
  }

  Widget _buildJourneyDetailsSheet(Jornada jornada) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.whiteShade,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grayShade.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Journey Title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jornada.titulo,
                      style: AppFont.title,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      jornada.descricao,
                      style: AppFont.bodyText,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        _buildJourneyInfoChip(
                            Icons.access_time, '${jornada.tempoEstimado} min'),
                        const SizedBox(width: 10),
                        _buildJourneyInfoChip(
                            Icons.quiz, '${jornada.testes.length} testes'),
                      ],
                    ),
                    // Progress bar
                    if (jornada.iniciada) ...[
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            'Progresso: ${(jornada.progresso * 100).toInt()}%',
                            style: AppFont.smallText
                                .copyWith(color: AppColors.darkText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: jornada.progresso,
                          backgroundColor: AppColors.progressBarBackground,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Content List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Conteu00fados',
                  style: AppFont.subtitle,
                ),
              ),

              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: jornada.conteudos.length,
                  itemBuilder: (context, index) {
                    final conteudo = jornada.conteudos[index];
                    return _buildContentCard(conteudo, jornada);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJourneyInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.secondaryColor,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(Conteudo conteudo, Jornada jornada) {
    // Find associated test for this content (if any)
    final teste = jornada.testes.firstWhere(
      (t) => t.conteudoId == conteudo.id,
      orElse: () => Teste(
        id: '',
        titulo: '',
        descricao: '',
        conteudoId: '',
        perguntas: [],
      ),
    );

    final hasTeste = teste.id.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: conteudo.visualizado
                        ? AppColors.successColor.withOpacity(0.2)
                        : AppColors.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    conteudo.tipo == 'ar' ? Icons.view_in_ar : Icons.article,
                    color: conteudo.visualizado
                        ? AppColors.successColor
                        : AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conteudo.titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        conteudo.descricao,
                        style: TextStyle(
                          color: AppColors.grayShade,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (conteudo.visualizado)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.successColor,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocalAndWebObjectsWidget(
                            uri: App3DModelLink.coracao),
                      ),
                    ),
                    // onPressed: () => _viewContent(conteudo, jornada.id),
                    icon: Icon(
                      conteudo.tipo == 'ar'
                          ? Icons.view_in_ar
                          : Icons.visibility,
                      size: 18,
                    ),
                    label: Text(
                        conteudo.tipo == 'ar' ? 'Ver em RA' : 'Visualizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.lightText,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (hasTeste) const SizedBox(width: 10),
                if (hasTeste)
                  OutlinedButton.icon(
                    onPressed: () => _startTest(teste),
                    icon: const Icon(Icons.quiz, size: 12),
                    label: const Text('Teste'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondaryColor,
                      side: BorderSide(color: AppColors.secondaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewContent(Conteudo conteudo, String jornadaId) {
    final appState = Provider.of<AppState>(context, listen: false);

    // Mark content as viewed
    if (!conteudo.visualizado && appState.userId != null) {
      appState.marcarConteudoVisualizado(jornadaId, conteudo.id);
    }

    if (conteudo.tipo == 'ar') {
      // Launch AR view
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ARViewScreen(arContent: conteudo.getArContent()),
        ),
      );
    } else {
      // For other content types, show a dialog or navigate to appropriate screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Visualizando ${conteudo.titulo}'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    }
  }

  void _startTest(Teste teste) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(teste: teste),
      ),
    ).then((_) {
      // Refresh data when returning from test
      final appState = Provider.of<AppState>(context, listen: false);
      appState.refreshData();
    });
  }
}
