import 'package:flutter/material.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/measurement/screens/pre_measurement_screen.dart';
import '../features/measurement/screens/measurement_screen.dart';
import '../features/measurement/screens/results_screen.dart';
import '../features/history/screens/history_screen.dart';
import '../features/history/screens/measurement_detail_screen.dart';
import '../features/reminders/screens/reminders_screen.dart';
import '../shared/models/measurement_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String preMeasurement = '/pre-measurement';
  static const String measurement = '/measurement';
  static const String results = '/results';
  static const String history = '/history';
  static const String measurementDetail = '/measurement-detail';
  static const String reminders = '/reminders';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case forgotPassword:
        return MaterialPageRoute(
            builder: (_) => const ForgotPasswordScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case preMeasurement:
        return MaterialPageRoute(
            builder: (_) => const PreMeasurementScreen());

      case measurement:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MeasurementScreen(
            method: args?['method'] ?? 'camera',
          ),
        );

      case results:
        final measurement = settings.arguments as MeasurementModel?;
        return MaterialPageRoute(
          builder: (_) => ResultsScreen(measurement: measurement),
        );

      case history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());

      case measurementDetail:
        final measurement = settings.arguments as MeasurementModel;
        return MaterialPageRoute(
          builder: (_) =>
              MeasurementDetailScreen(measurement: measurement),
        );

      case reminders:
        return MaterialPageRoute(builder: (_) => const RemindersScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
