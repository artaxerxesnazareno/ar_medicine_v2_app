import 'package:flutter/material.dart';
import 'package:ar_demo_ti/examples/localandwebobjectsexample.dart';
import 'package:ar_demo_ti/core/app_3d_models_links.dart';
import 'package:vector_math/vector_math_64.dart';

class ARExampleScreen extends StatelessWidget {
  const ARExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemplos AR'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildArModelButton(
            context, 
            title: 'Visualizar Coração 3D', 
            uri: App3DModelLink.coracao
          ),
          _buildArModelButton(
            context, 
            title: 'Visualizar Pato 3D', 
            uri: App3DModelLink.pato
          ),
          _buildArModelButton(
            context, 
            title: 'Visualizar Abacate 3D', 
            uri: App3DModelLink.abacate,
            scale: Vector3(4.0, 4.0, 4.0)
          ),
          _buildArModelButton(
            context, 
            title: 'Visualizar Peixe 3D', 
            uri: App3DModelLink.peixe,
            scale: Vector3(1.0, 1.0, 1.0)
          ),
          _buildArModelButton(
            context, 
            title: 'Visualizar Raposa 3D', 
            uri: App3DModelLink.raposa,
            scale: Vector3(0.1, 0.1, 0.1)
          ),
          _buildArModelButton(
            context, 
            title: 'Visualizar Garrafa de Água 3D', 
            uri: App3DModelLink.garrafaAgua,
            scale: Vector3(0.75, 0.75, 0.75)
          ),
        ],
      ),
    );
  }
  
  Widget _buildArModelButton(BuildContext context, {
    required String title,
    required String uri,
    Vector3? scale,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title),
        trailing: const Icon(Icons.view_in_ar),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LocalAndWebObjectsWidget(
                uri: uri,
                scale: scale,
              ),
            ),
          );
        },
      ),
    );
  }
} 