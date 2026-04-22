import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ICON / LOGO
            const Icon(
              Icons.support_agent,
              size: 80,
              color: Colors.white,
            ),

            const SizedBox(height: 20),

            // APP NAME
            const Text(
              'E-Ticketing Helpdesk',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            //  SUBTITLE
            const Text(
              'Solusi cepat untuk masalah IT',
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 40),

            // LOADING
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}