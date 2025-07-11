import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/create_report_screen.dart';

void main() {
  runApp(const CitizenApp());
}

class CitizenApp extends StatelessWidget {
  const CitizenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citizen',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/create-report': (context) => const CreateReportScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
