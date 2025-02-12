import 'package:flutter/material.dart';
import 'package:giat_cerika/services/profile_services.dart';
import '../constant/color.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  List<dynamic> _latestAttempts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      print('Loading profile data...');
      final profile = await _profileService.getProfile();
      print('Profile data received: $profile');

      print('Loading attempts data...');
      final attempts = await _profileService.getLatestAttempts();
      print('Attempts data received: $attempts');

      setState(() {
        _profileData = profile;
        _latestAttempts = attempts['attempts'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error in _loadData: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _TopPortion(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      _profileData?['fullName'] ?? 'User',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton.extended(
                          onPressed: () => _showEditProfileDialog(),
                          heroTag: 'edit',
                          elevation: 0,
                          backgroundColor: AppColors.accentColor3,
                          label: const Text("Edit Profil"),
                          icon: const Icon(Icons.edit),
                        ),
                        const SizedBox(width: 16.0),
                        FloatingActionButton.extended(
                          onPressed: () => _handleLogout(context),
                          heroTag: 'logout',
                          elevation: 0,
                          backgroundColor: Colors.red,
                          label: const Text("Logout"),
                          icon: const Icon(Icons.logout),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_latestAttempts.isNotEmpty) _buildLatestAttempts(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestAttempts() {
    return Container(
      height: 80,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _latestAttempts.asMap().entries.map((entry) {
          final attempt = entry.value;
          return Expanded(
            child: Row(
              children: [
                if (entry.key != 0) const VerticalDivider(),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${attempt['score']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM').format(
                          DateTime.parse(attempt['date']),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _showEditProfileDialog() async {
    final fullNameController = TextEditingController(
      text: _profileData?['fullName'] ?? '',
    );
    final usernameController = TextEditingController(
      text: _profileData?['username'] ?? '',
    );
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password Baru (opsional)',
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _profileService.updateProfile(
                  fullName: fullNameController.text,
                  username: usernameController.text,
                  password: passwordController.text.isEmpty
                      ? null
                      : passwordController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil berhasil diperbarui')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentColor3,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentColor2,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _TopPortion extends StatelessWidget {
  const _TopPortion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Tetapkan tinggi spesifik
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 50),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.accentColor3,
                  AppColors.accentColor3.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 150,
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.backgroundColor,
                        width: 3,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
