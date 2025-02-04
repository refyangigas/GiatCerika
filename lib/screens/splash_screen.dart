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
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryColor.withOpacity(0.1),
              AppColors.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Lottie Animation
              SizedBox(
                height: size.height * 0.5,
                child: Lottie.asset(
                  'assets/animations/splash.json',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 35),
              // Title and Subtitle
              Text(
                'Giat Cerika',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Belajar Menyenangkan,\nPrestasi Membanggakan!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondaryColor,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              // Loading Indicator
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
