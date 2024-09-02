import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Import pentru Firebase Core
import 'package:flutter_ecommerce_app/src/config/route.dart';
import 'package:flutter_ecommerce_app/src/pages/mainPage.dart';
import 'package:flutter_ecommerce_app/src/pages/product_detail.dart';
import 'package:flutter_ecommerce_app/src/widgets/customRoute.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ecommerce_app/src/pages/login_page.dart';
import 'firebase_options.dart';  // Importă fișierul de opțiuni Firebase

import 'src/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Asigură-te că asta este înainte de Firebase.initializeApp
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // Inițializează Firebase cu opțiunile corecte
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
      routes: Routes.getRoute(),
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name?.contains('detail') ?? false) {
          return CustomRoute<bool>(
            builder: (BuildContext context) => ProductDetailPage(),
          );
        } else {
          return CustomRoute<bool>(
            builder: (BuildContext context) => AuthWrapper(),
          );
        }
      },
      initialRoute: "MainPage",
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
          return MainPage();  // Utilizatorul este autentificat
        } else {
          return LoginPage();  // Utilizatorul nu este autentificat
        }
      },
    );
  }
}
