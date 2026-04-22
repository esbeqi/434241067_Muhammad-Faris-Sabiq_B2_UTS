import 'package:flutter/material.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'features/ticket/presentation/providers/ticket_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void toggleTheme(BuildContext context) {
    final _MyAppState? state =
    context.findAncestorStateOfType<_MyAppState>();
    state?.toggleTheme();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = true;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TicketProvider()..loadTickets(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        home: const SplashPage(),
      ),
    );
  }
}