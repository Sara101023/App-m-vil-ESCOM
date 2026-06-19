import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/alumno_provider.dart';
import '../../../../core/theme/app_colors.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _verPassword = false;
  bool _modoAdmin = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final alumnoState = ref.watch(alumnoProvider);

    // Navegación cuando admin inicia sesión
    ref.listen(authProvider, (prev, next) {
      if (next.isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/admin/dashboard');
      }
    });

    // Navegación cuando alumno inicia sesión
    ref.listen(alumnoProvider, (prev, next) {
      if (next.isLoggedIn && !next.estaCargando) {
        Navigator.of(context).pushReplacementNamed('/alumno/home');
      }
    });

    final estaCargando =
        authState.estaCargando || alumnoState.estaCargando;
    final error = authState.error ?? alumnoState.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Logo ──────────────────────────────
                const Icon(Icons.school_rounded,
                    color: AppColors.primary, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'ESCOM · IPN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sistema ETS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Toggle alumno/admin ────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _modoAdmin = false;
                            _userCtrl.clear();
                            _passCtrl.clear();
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_modoAdmin
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Alumno',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !_modoAdmin
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _modoAdmin = true;
                            _userCtrl.clear();
                            _passCtrl.clear();
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _modoAdmin
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Administrador',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _modoAdmin
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Formulario ────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLabel(
                          _modoAdmin ? 'Usuario' : 'Número de boleta'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _userCtrl,
                        hint: _modoAdmin ? 'admin' : '10 dígitos',
                        icon: _modoAdmin
                            ? Icons.person_outline_rounded
                            : Icons.badge_outlined,
                        keyboardType: _modoAdmin
                            ? TextInputType.text
                            : TextInputType.number,
                        maxLength: _modoAdmin ? null : 10,
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Contraseña'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _passCtrl,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscure: !_verPassword,
                        suffix: IconButton(
                          onPressed: () =>
                              setState(() => _verPassword = !_verPassword),
                          icon: Icon(
                            _verPassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),

                      if (error != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(error,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: estaCargando
                              ? null
                              : () {
                                  if (_modoAdmin) {
                                    ref.read(authProvider.notifier).login(
                                          _userCtrl.text.trim(),
                                          _passCtrl.text,
                                        );
                                  } else {
                                    ref
                                        .read(alumnoProvider.notifier)
                                        .login(
                                          _userCtrl.text.trim(),
                                          _passCtrl.text,
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: estaCargando
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500));

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5)),
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}