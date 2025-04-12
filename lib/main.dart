import 'package:ar_demo_ti/Presentation/login/login_screen.dart';
import 'package:ar_demo_ti/Presentation/theme/theme.dart';
import 'package:ar_demo_ti/util/iframe_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/jornada_model.dart';
import 'models/teste_model.dart';
import 'models/user_model.dart';

void main() {
  dfInitMessageListener();
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MultiProvider(
    providers: [
      // Add providers for state management
      ChangeNotifierProvider(create: (_) => AppState()),
    ],
    child: const MedicalARApp(),
  ));
}

class MedicalARApp extends StatelessWidget {
  const MedicalARApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediAR',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

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

/*
import 'dart:async';

import 'package:ar_demo_ti/examples/localandwebobjectsexample.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  static bool isButtonEnabled = false;
  String _platformVersion = 'Unknown';
  static const String _title = 'AR Demo';
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    initPlatformState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Widget _infoTile(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle.isEmpty ? 'Not set' : subtitle),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {
      //developer.log('TI:Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
      //print("TI:connectivity status:" '$_connectionStatus');
      _MyAppState.isButtonEnabled =
          (_connectionStatus.name == 'none') ? false : true;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await ArFlutterPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(_title),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/720x1520-background2.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(children: [
            Center(
                heightFactor: 1.0,
                child: Text(
                  'Internet: ${_connectionStatus.toString()}',
                  textScaleFactor: 1.5,
                )),
            Text(
              'Running on: $_platformVersion\n',
            ),
            const Expanded(
              child: ExampleList(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _infoTile('App name', _packageInfo.appName),
                _infoTile('Package name', _packageInfo.packageName),
                _infoTile('App version', _packageInfo.version),
                // _infoTile('Build number', _packageInfo.buildNumber),
                // _infoTile('Build signature', _packageInfo.buildSignature),
                //_infoTile(
                //  'Installer store',
                //  _packageInfo.installerStore ?? 'not available',
                // ),
              ],
            ),
            const Text(
              'Copyright©Tiszai 2023, All Rights Reserved.',
              style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 12.0,
                  color: Color(0xFF162A49)),
            ),
          ]),
        ),
      ),
    );
  }
}

class ExampleList extends StatelessWidget {
  const ExampleList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final examples = [
      Example(
          'Online Object',
          'Place 3D objects the web into the scene.\nElhelyez a webről egy 3D testet a kamera képre.',
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LocalAndWebObjectsWidget(
                    models: ModelRepository.getModels(),
                  )))),
    ];
    return ListView(
      children:
          examples.map((example) => ExampleCard(example: example)).toList(),
    );
  }
}

class ExampleCard extends StatelessWidget {
  const ExampleCard({Key? key, required this.example}) : super(key: key);
  final Example example;

  @override
  build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 187, 235, 241),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          //  print("TI:connectivity status 1" '$_MyAppState.isButtonEnabled');
          if (_MyAppState.isButtonEnabled) {
            example.onTap();
          } else {
            //example.onTap();
            showAlertDialog(context, "Internet", '''         Not connected!
               Turn on!
Nincs az internet bekapcsolva!
             Kapcsolja be!''');
          }
        },
        child: ListTile(
          title: Text(example.name),
          subtitle: Text(example.description),
        ),
      ),
    );
  }
}

class Example {
  const Example(this.name, this.description, this.onTap);

  final String name;
  final String description;
  final Function onTap;
}

void showAlertDialog(BuildContext context, String top, String message) {
  // set up the button
  Widget okButton = TextButton(
    child: const Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    // title: const Text("Internet"),
    title: Text(top),
    content: Text(message, maxLines: 25),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
*/
