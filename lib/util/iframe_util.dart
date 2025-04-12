// Este arquivo contém código para fazer o aplicativo funcionar no modo iframe
// Adaptado para suportar múltiplas plataformas (web, Android, iOS)

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

// Inicializa o listener de mensagens para incorporação de iframe
void dfInitMessageListener() {
  // Em plataformas móveis, não faz nada (função vazia)
  // Na Web, seria necessário implementar o código JS adequado
  if (kIsWeb) {
    // Esta implementação não faz nada para evitar erros de compilação
    // A implementação real para web deve ser feita em um arquivo separado
    // e incluída usando conditional imports
  }
}

// Notifica o iframe pai sobre a ação do usuário (para análises)
void dfTrackEvent(String eventName, Map<String, dynamic> data) {
  // Em plataformas móveis, não faz nada (função vazia)
  if (kIsWeb) {
    // Em ambiente web, seria necessário usar JS para postar mensagens
    // Esta implementação não faz nada para evitar erros de compilação
  }
}
