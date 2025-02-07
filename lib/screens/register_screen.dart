import 'package:flutter/material.dart';
import 'package:giat_cerika/screens/login_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:giat_cerika/constant/color.dart';
import 'package:animate_do/animate_do.dart';
import 'package:giat_cerika/services/auth_services.dart';
import 'package:giat_cerika/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Username validation pattern
  final RegExp _usernamePattern = RegExp(r'^[A-Za-z0-9._-]{4,15}$');

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mohon masukkan nama lengkap';
    }
    if (value.trim() == _usernameController.text.trim()) {
      return 'Nama lengkap tidak boleh sama dengan username';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mohon masukkan username';
    }
    if (value.length < 4) {
      return 'Username minimal 4 karakter';
    }
    if (value.length > 15) {
      return 'Username maksimal 15 karakter';
    }
    if (!_usernamePattern.hasMatch(value)) {
      return 'Username hanya boleh mengandung huruf, angka, dan karakter . _ -';
    }
    if (value.contains(' ')) {
      return 'Username tidak boleh mengandung spasi';
    }
    if (value.trim() == _fullNameController.text.trim()) {
      return 'Username tidak boleh sama dengan nama lengkap';
    }
    // TODO: Add check for username uniqueness from backend
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mohon masukkan password';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mohon konfirmasi password';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await _authService.register(
          _fullNameController.text,
          _usernameController.text,
          _passwordController.text,
        );

        if (!mounted) return;

        if (response.containsKey('token')) {
          await context.read<AuthProvider>().setToken(response['token']);
          _showSnackBar('Registrasi berhasil', false);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          _showSnackBar(response['message'] ?? 'Registrasi gagal', true);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
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
          ),
          // Horizontal wave decoration
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: HorizontalWaveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                color: AppColors.accentColor2.withOpacity(0.1),
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: Lottie.asset(
                        'assets/animations/women.json',
                        height: 200,
                      ),
                    ),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          Text(
                            'Buat Akun Baru',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Silakan lengkapi data diri Anda',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Full Name Field
                    FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap',
                            prefixIcon: const Icon(Icons.person,
                                color: AppColors.primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: _validateFullName,
                          onChanged: (value) {
                            // Trigger form validation when fullname changes
                            _formKey.currentState?.validate();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Username Field
                    FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.account_circle,
                                color: AppColors.primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            helperText: '4-15 karakter (A-Z, 0-9, . _ -)',
                          ),
                          validator: _validateUsername,
                          onChanged: (value) {
                            // Trigger form validation when username changes
                            _formKey.currentState?.validate();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock,
                                color: AppColors.primaryColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: _validatePassword,
                          onChanged: (value) {
                            // Trigger confirm password validation when password changes
                            _formKey.currentState?.validate();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Confirm Password Field
                    FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Konfirmasi Password',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.primaryColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: _validateConfirmPassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Register Button
                    FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: InkWell(
                        onTap: _handleRegister,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Lottie.asset(
                              'assets/animations/buttons.json',
                              height: 80,
                            ),
                            _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'Daftar',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Login Link
                    FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah punya akun? ',
                            style:
                                TextStyle(color: AppColors.textSecondaryColor),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper untuk membuat gelombang horizontal
class HorizontalWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);

    final firstStart = Offset(size.width * 0.3, size.height);
    final firstEnd = Offset(size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(
      firstStart.dx,
      firstStart.dy,
      firstEnd.dx,
      firstEnd.dy,
    );

    final secondStart = Offset(size.width * 0.7, 0);
    final secondEnd = Offset(size.width, size.height * 0.3);
    path.quadraticBezierTo(
      secondStart.dx,
      secondStart.dy,
      secondEnd.dx,
      secondEnd.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
