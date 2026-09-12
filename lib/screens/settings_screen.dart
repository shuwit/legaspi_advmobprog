import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import '../widgets/custom_font.dart';

// Enhancement 2 Legaspi
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Enhancement 2 Legaspi
  Future<void> _signOut(BuildContext context) async {
    try {
      await UserService().logout();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const CustomFont(
          text: 'Settings',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF1877F2),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Enhancement 2 Legaspi: user preference
          SwitchListTile(
            title: const CustomFont(text: 'Dark Mode', fontSize: 14),
            subtitle: const CustomFont(
              text: 'Toggle light / dark theme preference',
              fontSize: 12,
              color: Colors.grey,
            ),
            value: themeProvider.isDark,
            activeThumbColor: const Color(0xFF1877F2),
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          const Divider(),
          // Enhancement 2 Legaspi: Sign Out button
          ListTile(
            leading: Icon(Icons.logout, color: Colors.redAccent, size: 22.sp),
            title: const CustomFont(
              text: 'Sign Out',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.redAccent,
            ),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
