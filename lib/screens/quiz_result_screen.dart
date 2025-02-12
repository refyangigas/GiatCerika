import 'package:flutter/material.dart';
import '../constant/color.dart';
import 'package:lottie/lottie.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final VoidCallback onRetry;
  final VoidCallback onFinish;

  const QuizResultScreen({
    Key? key,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.onRetry,
    required this.onFinish,
  }) : super(key: key);

  String _getMotivationalText() {
    if (score >= 80) {
      return 'Luar biasa! Pertahankan prestasimu!';
    } else if (score >= 60) {
      return 'Bagus! Terus tingkatkan pemahamanmu!';
    } else {
      return 'Jangan menyerah! Coba lagi untuk hasil yang lebih baik!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        onFinish();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Lottie.asset(
                    score >= 60
                        ? 'assets/animations/success1.json'
                        : 'assets/animations/fail1.json',
                    height: 200,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Hasil Quiz',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$score',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentColor3,
                          ),
                        ),
                        Text(
                          'Skor Anda',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatItem(
                              correctAnswers.toString(),
                              'Benar',
                              Colors.green,
                            ),
                            const SizedBox(width: 24),
                            _buildStatItem(
                              (totalQuestions - correctAnswers).toString(),
                              'Salah',
                              Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _getMotivationalText(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentColor3,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigasi ke home screen dengan mengganti semua route sebelumnya
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/home', (route) => false);
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Selesai'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentColor3,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondaryColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
