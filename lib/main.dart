import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_app/screens/onboarding_screen.dart';
import 'package:quizlet_app/screens/splash_screen.dart'; 
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        splash: const SplashScreen(), 
        nextScreen:  const OnboardingScreen(), 
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.white,
        duration: 2000, 
      ),
    );
  }
}
