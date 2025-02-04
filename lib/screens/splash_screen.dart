import 'package:flutter/material.dart';
import 'package:giat_cerika/screens/welcome_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:giat_cerika/constant/color.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kids learning animation
            SizedBox(
              height: size.height * 0.4,
              child: Lottie.asset(
                'assets/animations/kids-learning1.json',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: size.height * 0.05),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Text(
                    'Giat Cerika',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                      strokeWidth: 4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
