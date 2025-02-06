// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giat_cerika/constant/color.dart';
import 'package:giat_cerika/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
 const ProfileScreen({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: AppColors.backgroundColor,
     body: SafeArea(
       child: Padding(
         padding: const EdgeInsets.all(20.0),
         child: Column(
           children: [
             const CircleAvatar(
               radius: 50,
               backgroundColor: AppColors.primaryColor,
               child: Icon(Icons.person, size: 50, color: Colors.white),
             ),
             const SizedBox(height: 20),
             Text(
               'Username', // Nanti diganti dengan data user dari backend
               style: TextStyle(
                 fontSize: 24,
                 fontWeight: FontWeight.bold,
                 color: AppColors.textPrimaryColor,
               ),
             ),
             const SizedBox(height: 40),
             _buildProfileItem(Icons.person, 'Profile Saya'),
             _buildProfileItem(Icons.star, 'Nilai Tes'),
             _buildDivider(),
             _buildProfileItem(
               Icons.logout,
               'Logout',
               onTap: () => _handleLogout(context),
             ),
           ],
         ),
       ),
     ),
   );
 }

 Widget _buildProfileItem(IconData icon, String title, {VoidCallback? onTap}) {
   return ListTile(
     leading: Icon(icon, color: AppColors.primaryColor),
     title: Text(title),
     trailing: const Icon(Icons.arrow_forward_ios, size: 16),
     onTap: onTap,
   );
 }

 Widget _buildDivider() {
   return const Padding(
     padding: EdgeInsets.symmetric(vertical: 8.0),
     child: Divider(thickness: 1),
   );
 }

 void _handleLogout(BuildContext context) {
   showDialog(
     context: context,
     builder: (context) => AlertDialog(
       title: const Text('Logout'),
       content: const Text('Apakah Anda yakin ingin keluar?'),
       actions: [
         TextButton(
           onPressed: () => Navigator.pop(context),
           child: const Text('Batal'),
         ),
         TextButton(
           onPressed: () {
             context.read<AuthProvider>().logout();
             Navigator.pushReplacementNamed(context, '/login');
           },
           child: const Text('Ya'),
         ),
       ],
     ),
   );
 }
}