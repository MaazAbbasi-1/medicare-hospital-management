import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'admin_dashboard_screen.dart';
import 'doctor_dashboard_screen.dart';
import 'home_screen.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AuthService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        switch (snapshot.data) {
          case 'doctor':
            return const DoctorDashboardScreen();
          case 'admin':
            return const AdminDashboardScreen();
          default:
            return const HomeScreen();
        }
      },
    );
  }
}
