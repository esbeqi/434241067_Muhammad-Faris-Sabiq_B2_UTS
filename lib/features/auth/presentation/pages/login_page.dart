import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/colors.dart';
import '../../../dashboard/presentation/pages/dashboard_user_page.dart';
import '../../../dashboard/presentation/pages/dashboard_admin_page.dart';
import '../../../dashboard/presentation/pages/dashboard_helpdesk_page.dart';
import '../widgets/auth_widgets.dart';
import '../providers/auth_provider.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua field')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    try {
      final success = await authProvider.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (success && mounted) {
        _navigateToDashboard(authProvider.role);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal: $e')),
        );
      }
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.secondary : AppColors.lightBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.confirmation_number,
                    size: 52,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'E-Ticketing Helpdesk',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan login untuk melanjutkan',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),
                AuthTextField(
                  hint: 'Email',
                  controller: emailController,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  hint: 'Password',
                  isPassword: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 20),
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : AuthButton(
                        text: 'Login',
                        onTap: login,
                      ),
                const SizedBox(height: 12),
                AuthLink(
                  text: 'Belum punya akun? ',
                  actionText: 'Daftar',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: const Text('Lupa Password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
