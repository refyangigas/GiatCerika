import 'package:flutter/material.dart';
import 'package:giat_cerika/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:giat_cerika/providers/auth_provider.dart';
import 'package:giat_cerika/screens/home_screen.dart';
import 'package:giat_cerika/screens/login_screen.dart';
import 'package:giat_cerika/screens/register_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Giat Cerika',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Tambahkan ini
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
