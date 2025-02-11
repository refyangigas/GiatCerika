import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constant/color.dart';
import '../models/quiz.dart';
import '../services/quiz_services.dart';
import '../providers/auth_provider.dart';
import 'quiz_result_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QuizPlayScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizPlayScreen({
    Key? key,
    required this.quiz,
  }) : super(key: key);

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  final QuizService _quizService = QuizService();
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  final Map<int, String> _userAnswers = {};
  int _correctAnswers = 0;
  bool _isSubmitting = false;

  QuizQuestion get _currentQuestion =>
      widget.quiz.questions[_currentQuestionIndex];

  void _retryQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _userAnswers.clear();
      _correctAnswers = 0;
      _isSubmitting = false;
    });
  }

  void _finishQuiz() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _submitQuiz() async {
    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.userId;

      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Calculate correct answers and prepare submission data
      _correctAnswers = 0;
      final answers = _userAnswers.entries.map((entry) {
        final question = widget.quiz.questions[entry.key];
        final selectedOption =
            question.options.firstWhere((opt) => opt.text == entry.value);

        if (selectedOption.isCorrect) {
          _correctAnswers++;
        }

        return {
          'question': question.text,
          'selectedOption': selectedOption.text,
          'isCorrect': selectedOption.isCorrect,
        };
      }).toList();

      // Calculate final score
      final score =
          (_correctAnswers / widget.quiz.questions.length * 100).round();

      // Submit to API
      await _quizService.submitQuizAttempt(
        quizId: widget.quiz.id,
        userId: userId,
        answers: answers,
        score: score,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(
              score: score,
              correctAnswers: _correctAnswers,
              totalQuestions: widget.quiz.questions.length,
              onRetry: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPlayScreen(quiz: widget.quiz),
                  ),
                );
              },
              onFinish: _finishQuiz,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _nextQuestion() {
    if (_selectedAnswer == null) return;

    setState(() {
      _userAnswers[_currentQuestionIndex] = _selectedAnswer!;
      if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
        _currentQuestionIndex++;
        _selectedAnswer = _userAnswers[_currentQuestionIndex];
      } else {
        _submitQuiz();
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedAnswer = _userAnswers[_currentQuestionIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Keluar Quiz?'),
                content: const Text(
                    'Progress quiz Anda akan hilang. Yakin ingin keluar?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Tidak'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Ya'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentColor3,
                  const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
                ],
              ),
            ),
          ),
          title: Text(
            widget.quiz.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevation: 4,
          shadowColor: AppColors.accentColor3.withOpacity(0.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: _isSubmitting
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress indicator
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentColor3.withOpacity(0.2),
                            AppColors.accentColor3.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (_currentQuestionIndex + 1) /
                                  widget.quiz.questions.length,
                              backgroundColor:
                                  AppColors.accentColor3.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.accentColor3),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Soal ${_currentQuestionIndex + 1} dari ${widget.quiz.questions.length}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${((_currentQuestionIndex + 1) / widget.quiz.questions.length * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: AppColors.accentColor3,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Question
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentQuestion.text,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_currentQuestion.image != null) ...[
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: _currentQuestion.image!.url,
                                  placeholder: (context, url) => Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.error),
                                    ),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Options
                    ...List.generate(_currentQuestion.options.length, (index) {
                      final option = _currentQuestion.options[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _selectedAnswer == option.text
                                ? AppColors.accentColor3
                                : Colors.grey.shade300,
                            width: _selectedAnswer == option.text ? 2 : 1,
                          ),
                        ),
                        child: RadioListTile<String>(
                          title: Text(option.text),
                          value: option.text,
                          groupValue: _selectedAnswer,
                          activeColor: AppColors.accentColor3,
                          onChanged: (value) =>
                              setState(() => _selectedAnswer = value),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _currentQuestionIndex > 0
                              ? _previousQuestion
                              : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Sebelumnya'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentColor3,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed:
                              _selectedAnswer != null ? _nextQuestion : null,
                          icon: Icon(_currentQuestionIndex <
                                  widget.quiz.questions.length - 1
                              ? Icons.arrow_forward
                              : Icons.check_circle),
                          label: Text(_currentQuestionIndex <
                                  widget.quiz.questions.length - 1
                              ? 'Selanjutnya'
                              : 'Selesai'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentColor3,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
