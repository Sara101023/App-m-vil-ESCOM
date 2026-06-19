import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/alumno_repository_impl.dart';
import '../../domain/entities/alumno_entity.dart';

class AlumnoState {
  final AlumnoEntity? alumno;
  final bool estaCargando;
  final String? error;

  bool get isLoggedIn => alumno != null;

  const AlumnoState({
    this.alumno,
    this.estaCargando = false,
    this.error,
  });

  AlumnoState copyWith({
    AlumnoEntity? alumno,
    bool? estaCargando,
    String? error,
    bool limpiarAlumno = false,
    bool limpiarError = false,
  }) {
    return AlumnoState(
      alumno: limpiarAlumno ? null : (alumno ?? this.alumno),
      estaCargando: estaCargando ?? this.estaCargando,
      error: limpiarError ? null : (error ?? this.error),
    );
  }
}

class AlumnoNotifier extends Notifier<AlumnoState> {
  @override
  AlumnoState build() => const AlumnoState();

  final _repo = AlumnoRepositoryImpl();

  Future<void> login(String boleta, String password) async {
    if (boleta.isEmpty || password.isEmpty) {
      state = state.copyWith(error: 'Ingresa tu boleta y contraseña');
      return;
    }
    if (boleta.length != 10) {
      state = state.copyWith(error: 'La boleta debe tener 10 dígitos');
      return;
    }
    state = state.copyWith(estaCargando: true, limpiarError: true);
    try {
      final alumno = await _repo.login(boleta, password);
      if (alumno != null) {
        state = state.copyWith(alumno: alumno, estaCargando: false);
      } else {
        state = state.copyWith(
          estaCargando: false,
          error: 'Boleta o contraseña incorrectos',
        );
      }
    } catch (e) {
      state = state.copyWith(
        estaCargando: false,
        error: 'Error de conexión. Intenta de nuevo.',
      );
    }
  }

  void logout() => state = const AlumnoState();
}

final alumnoProvider =
    NotifierProvider<AlumnoNotifier, AlumnoState>(AlumnoNotifier.new);