import 'package:go_router/go_router.dart';
import 'package:hst_scribe/features/auth/presentation/login_screen.dart';
import 'package:hst_scribe/features/capture/presentation/session_capture_screen.dart';
import 'package:hst_scribe/features/session/presentation/patient_confirm_screen.dart';
import 'package:hst_scribe/features/session/presentation/session_list_screen.dart';
import 'package:hst_scribe/features/session/presentation/session_start_screen.dart';
import 'package:hst_scribe/features/session/presentation/splash_screen.dart';
import 'package:hst_scribe/features/sign/presentation/session_sign_screen.dart';
import 'package:hst_scribe/features/sign/presentation/settings_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

/// Type-safe route names. Feature code calls `context.goNamed(Routes.x)`.
/// No string paths in widgets — change the value here and the call sites
/// keep working.
abstract final class Routes {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String sessionList = 'session_list';
  static const String sessionStart = 'session_start';
  static const String sessionPatientConfirm = 'session_patient_confirm';
  static const String sessionCapture = 'session_capture';
  static const String sessionSign = 'session_sign';
  static const String settings = 'settings';
}

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: Routes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: Routes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/sessions',
        name: Routes.sessionList,
        builder: (_, __) => const SessionListScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'start',
            name: Routes.sessionStart,
            builder: (_, __) => const SessionStartScreen(),
          ),
          GoRoute(
            path: ':sessionId/patient',
            name: Routes.sessionPatientConfirm,
            builder: (_, GoRouterState state) {
              final id = state.pathParameters['sessionId'] ?? '';
              return PatientConfirmScreen(sessionId: id);
            },
          ),
          GoRoute(
            path: ':sessionId/capture',
            name: Routes.sessionCapture,
            builder: (_, GoRouterState state) {
              final id = state.pathParameters['sessionId'] ?? '';
              return SessionCaptureScreen(sessionId: id);
            },
          ),
          GoRoute(
            path: ':sessionId/sign',
            name: Routes.sessionSign,
            builder: (_, GoRouterState state) {
              final id = state.pathParameters['sessionId'] ?? '';
              return SessionSignScreen(sessionId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        name: Routes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
    ],
  );
}
