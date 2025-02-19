import 'package:flutter/material.dart';
import 'package:quizlet_app/screens/home_screen.dart';
import 'package:quizlet_app/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isFirstRun = true;

  @override
  void initState() {
    super.initState();
    _checkLoggedIn();
    _checkFirstRun();
  }

  void _checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'letquiz.',
              style: TextStyle(
                fontSize: 50,
                color: Color(0xFF0F2167),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(), // Hiển thị tiến trình khi kiểm tra trạng thái đăng nhập
          ],
        ),
      ),
    );
  }

  void _checkFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn && isFirstRun) {
      isFirstRun = false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }
}
