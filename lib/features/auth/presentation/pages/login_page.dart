import 'package:flutter/material.dart';

import '../../../../core/colors.dart';
import '../../../dashboard/presentation/pages/dashboard_user_page.dart';
import '../../../dashboard/presentation/pages/dashboard_admin_page.dart';
import '../../../dashboard/presentation/pages/dashboard_helpdesk_page.dart';
import '../widgets/auth_widgets.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String selectedRole = 'user';

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() {
    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua field')),
      );
      return;
    }

    if (selectedRole == 'user') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardUserPage(),
        ),
      );
    } else if (selectedRole == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardAdminPage(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardHelpdeskPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

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
                // LOGO (ORANGE STYLE)
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

                // TITLE
                Text(
                  'E-Ticketing Helpdesk',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                // SUBTITLE
                Text(
                  'Silakan login untuk melanjutkan',
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 40),

                // USERNAME
                AuthTextField(
                  hint: 'Username',
                  controller: usernameController,
                ),

                const SizedBox(height: 16),

                // PASSWORD
                AuthTextField(
                  hint: 'Password',
                  isPassword: true,
                  controller: passwordController,
                ),

                const SizedBox(height: 16),

                // ROLE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color:
                    isDark ? AppColors.card : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: selectedRole,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor:
                    isDark ? AppColors.card : Colors.white,
                    items: const [
                      DropdownMenuItem(
                          value: 'user', child: Text('User')),
                      DropdownMenuItem(
                          value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(
                          value: 'helpdesk',
                          child: Text('Helpdesk')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // LOGIN BUTTON
                AuthButton(
                  text: 'Login',
                  onTap: login,
                ),

                const SizedBox(height: 12),

                // REGISTER
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

                // RESET PASSWORD
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reset password (simulasi)'),
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