# ETS's ESCOM — Sistema de Gestión de Exámenes a Título de Suficiencia

Aplicación móvil desarrollada en Flutter para la gestión integral de Exámenes a Título de Suficiencia (ETS) en la Escuela Superior de Cómputo (ESCOM) del Instituto Politécnico Nacional (IPN).

## Descripción

El sistema permite a los alumnos buscar, solicitar y dar seguimiento a sus ETS de forma digital, mientras que el personal administrativo gestiona los exámenes disponibles, controla cupos y responde solicitudes — todo con notificaciones en tiempo real y comprobantes exportables en PDF.

## Funcionalidades principales

### Alumno
- Búsqueda de ETS disponibles filtrados por carrera y semestre
- Solicitud de ETS al administrador con mensaje opcional
- Favoritos persistentes en el dispositivo (sqflite)
- Historial y próximos ETS inscritos
- Notificaciones push (Firebase) y recordatorios locales programados (1 día antes a las 20:00 y 2 horas antes del examen)
- Exportación de comprobante en PDF con logos institucionales
- Contacto directo con soporte vía correo electrónico

### Administrador
- CRUD completo de ETS con validación de fecha futura
- Gestión de alumnos (alta, edición, cambio de contraseña, baja)
- Aceptación/rechazo de solicitudes con control automático de cupo
- Auto-rechazo de solicitudes pendientes cuando el cupo se agota, con notificación a cada alumno afectado
- Dashboard con estadísticas en tiempo real

## Stack tecnológico

| Categoría | Tecnología |
|---|---|
| Framework | Flutter 3.x |
| Manejo de estado | Riverpod |
| Backend | Supabase (PostgreSQL + PostgREST + Edge Functions) |
| Notificaciones push | Firebase Cloud Messaging |
| Notificaciones locales | flutter_local_notifications |
| Base de datos local | sqflite |
| Persistencia ligera | shared_preferences |
| Inyección de dependencias | get_it |
| Generación de PDF | pdf + printing |
| Integraciones del dispositivo | url_launcher |
| Encriptación | crypto (SHA-256) |

## Arquitectura

El proyecto sigue los principios de **Clean Architecture**, separando cada módulo en tres capas:
presentation/   → Pages, Widgets, Providers (Riverpod)

domain/         → Entities, Repository Interfaces, Use Cases

data/           → Repository Implementations, Datasources

Los módulos `admin`, `ets` y `auth` implementan la separación completa (interfaz de repositorio + casos de uso). El módulo `alumno` mantiene una estructura simplificada debido a la cantidad de integraciones que coordina (Supabase, sqflite, notificaciones locales).

Supabase actúa como backend REST, consumido vía PostgREST — cumpliendo el rol de un API REST tradicional con endpoints JSON, complementado con Edge Functions para lógica de notificaciones push.

## Estructura del proyecto

lib/

├── core/                  # Configuración, DI, servicios compartidos, utilidades

├── features/

│   ├── admin/             # Gestión de ETS y alumnos (vista administrador)

│   ├── alumno/            # Búsqueda, solicitudes y favoritos (vista alumno)

│   ├── auth/              # Autenticación de administrador

│   ├── ets/               # Entidades y lógica compartida de ETS

│   └── splash/            # Pantalla de carga inicial

├── firebase_options.dart

└── main.dart

## Requisitos previos

- Flutter SDK ^3.11.0
- Una cuenta de Supabase con las tablas correspondientes (`ets`, `alumnos`, `solicitudes`, `ets_alumno`, `admins`)
- Un proyecto de Firebase con Cloud Messaging habilitado

## Instalación

```bash
git clone https://github.com/Sara101023/App-m-vil-ESCOM.git
cd App-m-vil-ESCOM
flutter pub get
flutter run
```

Configura tus credenciales de Supabase en `lib/core/config/supabase_config.dart` y agrega tu archivo `google-services.json` / `firebase_options.dart` según tu proyecto de Firebase.

## Autoría

Proyecto desarrollado como parte de la formación en Ingeniería en Sistemas Computacionales — ESCOM, IPN.