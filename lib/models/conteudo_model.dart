class Conteudo {
  final String id;
  final String titulo;
  final String tipo; // 'ar', 'video', 'texto', etc.
  final String dados; // AR model name, video URL, text content
  final String descricao;
  bool visualizado;

  Conteudo({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.dados,
    required this.descricao,
    this.visualizado = false,
  });

  factory Conteudo.fromJson(Map<String, dynamic> json) {
    return Conteudo(
      id: json['id'],
      titulo: json['titulo'],
      tipo: json['tipo'],
      dados: json['dados'],
      descricao: json['descricao'],
      visualizado: json['visualizado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'tipo': tipo,
      'dados': dados,
      'descricao': descricao,
      'visualizado': visualizado,
    };
  }

  // Método de cópia com modificações
  Conteudo copyWith({
    String? id,
    String? titulo,
    String? tipo,
    String? dados,
    String? descricao,
    bool? visualizado,
  }) {
    return Conteudo(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      tipo: tipo ?? this.tipo,
      dados: dados ?? this.dados,
      descricao: descricao ?? this.descricao,
      visualizado: visualizado ?? this.visualizado,
    );
  }

  // Mark content as viewed
  Future<void> visualizar() async {
    visualizado = true;
    // In a real implementation, we would save this to storage
    // For now, we're just marking it in memory
  }

  // Get AR content data
  ArContent getArContent() {
    if (tipo != 'ar') {
      throw Exception('This content is not AR content');
    }

    return ArContent(
      id: 'ar-$id',
      title: titulo,
      description: descricao,
      arModelName: dados,
    );
  }
}

// Keep the AR content class for compatibility with the AR view screen
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
