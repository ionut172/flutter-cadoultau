import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:google_fonts/google_fonts.dart';  // Import Google Fonts package

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Cadoul',  // First word
            style: GoogleFonts.poppins(
              fontSize: 50,  // Large size for "Cadoul"
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,  // Customize the color
            ),
          ),
          Text(
            'Tău',  // Second word
            style: GoogleFonts.poppins(
              fontSize: 40,  // Slightly smaller size for "Tău"
              fontWeight: FontWeight.w300,
              color: Colors.orangeAccent,  // Customize the color
            ),
          ),
        ],
      ),
      nextScreen: LoginPage(),  // Navigate to LoginPage after the splash screen
      splashTransition: SplashTransition.fadeTransition,
      duration: 3000,
      backgroundColor: Colors.white,  // Set background color of splash screen
    );
  }
}
