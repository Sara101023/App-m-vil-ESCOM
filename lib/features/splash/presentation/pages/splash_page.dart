import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {

  // Controlador para que el tiburón orbite
  late AnimationController _orbitController;
  // Controlador para el fade in del texto
  late AnimationController _fadeController;
  // Controlador para la barra de carga
  late AnimationController _loadingController;
  // Controlador para la mordida
  late AnimationController _biteController;

  late Animation<double> _fadeAnim;
  late Animation<double> _loadingAnim;
  late Animation<double> _subtitleFade;

  bool _showBiteMark = false;

  @override
  void initState() {
    super.initState();

    // ── Órbita: 4 segundos por vuelta, infinito ────────
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // ── Fade del título: 0.8s ─────────────────────────
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // ── Barra de carga: 3.5s ──────────────────────────
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _loadingAnim = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    );

    // ── Subtítulo fade: empieza a los 0.5s ────────────
    _subtitleFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    // ── Bitecontroller para el efecto de mordida ──────
    _biteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Secuencia de inicio
    _startSequence();
  }

  Future<void> _startSequence() async {
    // 1. Fade in del texto
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    _loadingController.forward();

    // 2. A los 2s, mostrar mordida
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) setState(() => _showBiteMark = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _showBiteMark = false);

    // 3. Al terminar la carga, navegar
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _fadeController.dispose();
    _loadingController.dispose();
    _biteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Área de animación ──────────────────────
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Círculo orbital decorativo
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                  ),

                  // Letras ESCOM con shake en la mordida
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: AnimatedBuilder(
                      animation: _orbitController,
                      builder: (context, child) {
                        // Shake cuando el tiburón muerde (cerca de 0.5 en la órbita)
                        final progress = _orbitController.value;
                        double shakeX = 0;
                        if (progress > 0.48 && progress < 0.55) {
                          shakeX = sin(progress * 80) * 4;
                        }
                        return Transform.translate(
                          offset: Offset(shakeX, 0),
                          child: child,
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Marca de mordida (aparece y desaparece)
                          AnimatedOpacity(
                            opacity: _showBiteMark ? 1 : 0,
                            duration: const Duration(milliseconds: 150),
                            child: Container(
                              width: 20,
                              height: 8,
                              margin: const EdgeInsets.only(bottom: 2),
                              child: CustomPaint(
                                painter: _BitePainter(),
                              ),
                            ),
                          ),
                          // Texto ESCOM
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            ).createShader(bounds),
                            child: const Text(
                              'ESCOM',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tiburón orbitando
                  AnimatedBuilder(
                    animation: _orbitController,
                    builder: (context, child) {
                      final angle = _orbitController.value * 2 * pi;
                      final radius = 110.0;

                      // Calcula posición en la órbita
                      final x = cos(angle) * radius;
                      final y = sin(angle) * radius * 0.6; // óvalo

                      // El tiburón apunta en dirección del movimiento
                      // +90 grados porque el SVG del tiburón apunta a la derecha
                      final direction = angle + pi / 2;

                      // Si está en la mitad inferior de la órbita, va detrás del texto
                      // (simulamos profundidad con opacidad)
                      final isBelow = sin(angle) > 0;

                      return Positioned(
                        left: 140 + x - 30,
                        top: 140 + y - 15,
                        child: Opacity(
                          opacity: isBelow ? 0.5 : 1.0,
                          child: Transform.rotate(
                            angle: direction,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: const _SharkWidget(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Subtítulo ──────────────────────────────
            FadeTransition(
              opacity: _subtitleFade,
              child: const Text(
                'ESCUELA SUPERIOR DE CÓMPUTO · IPN',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ── Barra de carga ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _loadingAnim,
                    builder: (context, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _loadingAnim.value,
                          backgroundColor:
                              AppColors.cardBackground,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          minHeight: 3,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Cargando sistema ETS...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget del tiburón dibujado con Canvas ─────────────────
class _SharkWidget extends StatelessWidget {
  const _SharkWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 30,
      child: CustomPaint(
        painter: _SharkPainter(),
      ),
    );
  }
}

class _SharkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = const Color(0xFF4A90A4);
    final bellyPaint = Paint()..color = const Color(0xFFB8D4DC);
    final finPaint = Paint()..color = const Color(0xFF3A7A8A);
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = const Color(0xFF1A1A2E);
    final toothPaint = Paint()..color = Colors.white;

    // Cuerpo
    final bodyPath = Path();
    bodyPath.addOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.45, size.height * 0.5),
        width: size.width * 0.7,
        height: size.height * 0.7,
      ),
    );
    canvas.drawPath(bodyPath, bodyPaint);

    // Vientre
    final bellyPath = Path();
    bellyPath.addOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.48, size.height * 0.6),
        width: size.width * 0.5,
        height: size.height * 0.4,
      ),
    );
    canvas.drawPath(bellyPath, bellyPaint);

    // Cola (triángulos)
    final tailPath = Path();
    tailPath.moveTo(size.width * 0.1, size.height * 0.5);
    tailPath.lineTo(0, size.height * 0.1);
    tailPath.lineTo(size.width * 0.12, size.height * 0.45);
    tailPath.close();
    canvas.drawPath(tailPath, finPaint);

    final tailPath2 = Path();
    tailPath2.moveTo(size.width * 0.1, size.height * 0.5);
    tailPath2.lineTo(0, size.height * 0.9);
    tailPath2.lineTo(size.width * 0.12, size.height * 0.55);
    tailPath2.close();
    canvas.drawPath(tailPath2, finPaint);

    // Aleta dorsal
    final finPath = Path();
    finPath.moveTo(size.width * 0.35, size.height * 0.15);
    finPath.lineTo(size.width * 0.3, 0);
    finPath.lineTo(size.width * 0.5, size.height * 0.15);
    finPath.close();
    canvas.drawPath(finPath, finPaint);

    // Cabeza
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.5),
      size.height * 0.38,
      bodyPaint,
    );

    // Ojo
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.3),
      3.5,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.83, size.height * 0.3),
      2,
      pupilPaint,
    );

    // Dientes (pequeños triángulos)
    for (int i = 0; i < 3; i++) {
      final toothPath = Path();
      final tx = size.width * 0.75 + i * 4.0;
      toothPath.moveTo(tx, size.height * 0.62);
      toothPath.lineTo(tx + 2, size.height * 0.8);
      toothPath.lineTo(tx + 4, size.height * 0.62);
      toothPath.close();
      canvas.drawPath(toothPath, toothPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Pintor de la marca de mordida ─────────────────────────
class _BitePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;

    // Dientes de arriba
    for (int i = 0; i < 4; i++) {
      final path = Path();
      final x = i * 5.0;
      path.moveTo(x, 0);
      path.lineTo(x + 2.5, size.height);
      path.lineTo(x + 5, 0);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}