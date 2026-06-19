import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityNotifier extends Notifier<bool> {
  @override
  bool build() {
    _escuchar();
    return true; // asumimos conectado al inicio, se corrige enseguida
  }

  void _escuchar() {
    Connectivity().checkConnectivity().then(_actualizar);
    Connectivity().onConnectivityChanged.listen(_actualizar);
  }

  void _actualizar(List<ConnectivityResult> resultados) {
    final conectado = resultados.any((r) => r != ConnectivityResult.none);
    state = conectado;
  }
}

final conectividadProvider = NotifierProvider<ConnectivityNotifier, bool>(
  ConnectivityNotifier.new,
);