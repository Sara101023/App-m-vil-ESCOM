import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/admin_entity.dart';
import '../../domain/usecases/login_admin_usecase.dart';

class AuthState {
  final AdminEntity? admin;
  final bool estaCargando;
  final String? error;
  bool get isLoggedIn => admin != null;

  const AuthState({this.admin, this.estaCargando = false, this.error});

  AuthState copyWith({AdminEntity? admin, bool? estaCargando, String? error,
      bool limpiarAdmin = false, bool limpiarError = false}) {
    return AuthState(
      admin: limpiarAdmin ? null : (admin ?? this.admin),
      estaCargando: estaCargando ?? this.estaCargando,
      error: limpiarError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  LoginAdminUseCase get _loginUseCase => getIt<LoginAdminUseCase>();

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      state = state.copyWith(error: 'Ingresa usuario y contraseña');
      return;
    }
    state = state.copyWith(estaCargando: true, limpiarError: true);
    try {
      final admin = await _loginUseCase.ejecutar(username, password);
      if (admin != null) {
        state = state.copyWith(admin: admin, estaCargando: false);
      } else {
        state = state.copyWith(estaCargando: false, error: 'Usuario o contraseña incorrectos');
      }
    } catch (e) {
      state = state.copyWith(estaCargando: false, error: 'Error al iniciar sesión: $e');
    }
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);