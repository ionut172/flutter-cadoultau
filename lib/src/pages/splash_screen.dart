import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:cadoultau/main.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Image.asset('assets/nike_logo.png'), // Ensure the logo file exists in assets
      nextScreen: AuthWrapper(),  // AuthWrapper will handle login state
      splashTransition: SplashTransition.fadeTransition,
      duration: 3000,
    );
  }
}
