import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_ecommerce_app/src/pages/splash_screen.dart'; 
import 'package:flutter_ecommerce_app/src/pages/mainPage.dart';
import 'package:flutter_ecommerce_app/src/pages/register_page.dart'; // Import RegisterPage
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ecommerce_app/src/pages/login_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce',
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.mulishTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: true,
      home: SplashScreen(),  // Start with SplashScreen
      routes: {
        'MainPage': (context) => MainPage(),
        'LoginPage': (context) => LoginPage(),
        'RegisterPage': (context) => RegisterPage(), // Add RegisterPage route
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return MainPage();  // User is authenticated
        } else {
          return LoginPage();  // User is not authenticated
        }
      },
    );
  }
}
