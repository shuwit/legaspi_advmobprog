import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart'; // Enhancement 2 Legaspi
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) async {
      await dotenv.load(fileName: 'assets/.env');
      // Enhancement 1 Legaspi: Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      runApp(const LegaspiAdvMobProg());
    },
  );
}

class LegaspiAdvMobProg extends StatelessWidget {
  const LegaspiAdvMobProg({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: ScreenUtilInit(
        designSize: const Size(412, 715),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (build, child) {
          final themeModel = build.watch<ThemeProvider>();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeModel.lightTheme.copyWith(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1877F2)),
            ),
            darkTheme: themeModel.darkTheme.copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1877F2),
                brightness: Brightness.dark,
              ),
            ),
            themeMode: themeModel.isDark ? ThemeMode.dark : ThemeMode.light,
            title: 'Facebook Replication',
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/signin': (context) => const SignInScreen(),
              '/signup': (context) => const SignUpScreen(), // Enhancement 2 Legaspi
              '/home': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
