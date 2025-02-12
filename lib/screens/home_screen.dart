// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:giat_cerika/constant/color.dart';
import 'package:giat_cerika/screens/profile_screen.dart';
import 'package:giat_cerika/screens/materi_screen.dart';
import 'package:giat_cerika/screens/video_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeContent(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondaryColor,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Pilih menu yang tersedia',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                childAspectRatio: 2.5,
                mainAxisSpacing: 20,
                children: [
                  _buildFeatureCard(
                    'Materi',
                    'assets/images/travel-bag.png',
                    AppColors.accentColor4,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MateriScreen(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    'Video Pembelajaran',
                    'assets/images/airballon.png',
                    AppColors.accentColor2,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VideoScreen(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    'Tes',
                    'assets/images/destination.png',
                    AppColors.accentColor3,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizScreen(),
                      ),
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

  Widget _buildFeatureCard(
    String title,
    String imagePath,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Image.asset(
                imagePath,
                height: 100,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
