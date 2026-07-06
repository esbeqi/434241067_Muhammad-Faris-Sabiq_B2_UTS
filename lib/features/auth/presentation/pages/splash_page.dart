import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/colors.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import '../../../dashboard/presentation/pages/dashboard_user_page.dart';
import '../../../dashboard/presentation/pages/dashboard_admin_page.dart';
import '../../../dashboard/presentation/pages/dashboard_helpdesk_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() {
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      final authProvider = context.read<AuthProvider>();
      
      if (authProvider.isAuthenticated) {
        _navigateToDashboard(authProvider.role);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  void _navigateToDashboard(String? role) {
    Widget nextScreen;
    switch (role) {
      case 'admin':
        nextScreen = const DashboardAdminPage();
        break;
      case 'helpdesk':
        nextScreen = const DashboardHelpdeskPage();
        break;
      default:
        nextScreen = const DashboardUserPage();
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.support_agent,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'E-Ticketing Helpdesk',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Solusi cepat untuk masalah IT',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
