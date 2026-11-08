import 'dart:async';

/// Canal de "o que a IA está fazendo agora". Os adaptadores e o pipeline
/// escrevem aqui; a tela de processamento mostra ao vivo.
class Activity {
  static final _c = StreamController<String>.broadcast();
  static Stream<String> get stream => _c.stream;
  static void log(String message) {
    if (!_c.isClosed) _c.add(message);
  }
}
