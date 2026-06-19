import 'package:get_it/get_it.dart';
import '../database/database_helper.dart';
import '../notifications/notification_service.dart';
import '../../features/ets/data/datasources/ets_mock_datasource.dart';
import '../../features/ets/data/repositories/ets_repository_impl.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/i_admin_repository.dart';
import '../../features/admin/domain/usecases/gestionar_ets_usecase.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/ets/domain/repositories/ets_repository.dart';
import '../../features/ets/domain/usecases/buscar_ets_usecase.dart';
import '../../features/ets/domain/usecases/obtener_catalogos_usecase.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/domain/usecases/login_admin_usecase.dart';

// Instancia global del localizador
final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Servicios core (singleton = una sola instancia) ──────
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper());
  getIt.registerSingleton<NotificationService>(NotificationService());

  // Inicializar notificaciones
  await getIt<NotificationService>().init();

  // ── Datasources ──────────────────────────────────────────
  getIt.registerLazySingleton<EtsMockDatasource>(() => EtsMockDatasource());

  // ── Repositorios ─────────────────────────────────────────
  getIt.registerLazySingleton<EtsRepositoryImpl>(
    () => EtsRepositoryImpl(getIt<EtsMockDatasource>()),
  );
  getIt.registerLazySingleton<EtsRepository>(
    () => getIt<EtsRepositoryImpl>(),
  );

  getIt.registerLazySingleton<BuscarEtsUseCase>(
    () => BuscarEtsUseCase(getIt<EtsRepository>()),
  );

  getIt.registerLazySingleton<ObtenerCatalogosUseCase>(
    () => ObtenerCatalogosUseCase(getIt<EtsRepository>()),
  );

  getIt.registerLazySingleton<IAdminRepository>(
    () => AdminRepositoryImpl(),
  );

  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(getIt<DatabaseHelper>()),
  );

  // ── Casos de uso ─────────────────────────────────────────
  getIt.registerLazySingleton<GestionarEtsUseCase>(
    () => GestionarEtsUseCase(getIt<IAdminRepository>()),
  );

  getIt.registerLazySingleton<LoginAdminUseCase>(
    () => LoginAdminUseCase(getIt<IAuthRepository>()),
  );
}