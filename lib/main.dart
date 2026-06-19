import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/admin/presentation/pages/dashboard_page.dart';
import 'features/admin/presentation/pages/ets_list_admin_page.dart';
import 'features/admin/presentation/pages/ets_form_page.dart';
import 'features/admin/presentation/pages/catalogos_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'features/alumno/presentation/pages/alumno_home_page.dart';
import 'features/admin/presentation/pages/solicitudes_admin_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/admin/presentation/pages/alumnos_admin_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/services/notificaciones_locales_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Crear canal de notificaciones para Android
  const channel = AndroidNotificationChannel(
    'ets_channel',
    'Notificaciones ETS',
    description: 'Notificaciones de solicitudes de ETS',
    importance: Importance.high,
  );

  final localNotifications = FlutterLocalNotificationsPlugin();
  await localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  // Inicializar el servicio de recordatorios programados
  await NotificacionesLocalesService.inicializar();

  // Listener para cuando la app está en foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      localNotifications.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'ets_channel',
            'Notificaciones ETS',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

  await setupDependencies();
  runApp(const ProviderScope(child: EtsApp()));
}

class EtsApp extends StatelessWidget {
  const EtsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema ETS - ESCOM IPN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/': (context) => const LoginPage(),
        '/admin/dashboard': (context) => const DashboardPage(),
        '/admin/ets/list': (context) => const EtsListAdminPage(),
        '/admin/ets/form': (context) => const EtsFormPage(),
        '/admin/catalogos': (context) => const CatalogosPage(),
        '/admin/solicitudes': (context) => const SolicitudesAdminPage(),
        '/alumno/home': (context) => const AlumnoHomePage(),
        '/admin/alumnos': (context) => const AlumnosAdminPage(),
      },
    );
  }
}