import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../widgets/auth_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void register() {
    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua field')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Register berhasil (simulasi)')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? AppColors.secondary : AppColors.lightBackground,

      appBar: AppBar(
        title: const Text('Register'),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Buat Akun Baru',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 8),

                const Text(
                  'Silakan isi data untuk mendaftar',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                AuthTextField(
                  hint: 'Username',
                  controller: usernameController,
                ),

                const SizedBox(height: 16),

                AuthTextField(
                  hint: 'Password',
                  isPassword: true,
                  controller: passwordController,
                ),

                const SizedBox(height: 20),

                AuthButton(
                  text: 'Daftar',
                  onTap: register,
                ),

                const SizedBox(height: 12),

                AuthLink(
                  text: 'Sudah punya akun? ',
                  actionText: 'Login',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}