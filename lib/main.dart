import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cadoultau/src/pages/splash_screen.dart'; 
import 'package:cadoultau/src/pages/mainPage.dart';
import 'package:cadoultau/src/pages/register_page.dart';
import 'package:cadoultau/src/pages/add_person_page.dart';
import 'package:cadoultau/src/config/route.dart';
import 'package:cadoultau/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Add this import
import 'package:cadoultau/src/pages/login_page.dart';
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
      title: 'Cadoul Tau',
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.mulishTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: true,
      home: SplashScreen(),  // Start with the splash screen
      routes: Routes.getRoute(),  // Use the route method
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> _checkIfPeopleExist(User? user) async {
    if (user == null) return false;

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      if (data.containsKey('favorite_people') && data['favorite_people'] != null) {
        List<dynamic> favoritePeople = data['favorite_people'] as List<dynamic>;
        return favoritePeople.isNotEmpty;
      }
    }
    return false;
  }

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
          return FutureBuilder<bool>(
            future: _checkIfPeopleExist(snapshot.data),
            builder: (context, AsyncSnapshot<bool> peopleSnapshot) {
              if (peopleSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (peopleSnapshot.hasData && peopleSnapshot.data == true) {
                return MainPage();  // If people exist, go to MainPage
              } else {
                return AddPersonPage();  // If no people, go to AddPersonPage
              }
            },
          );
        } else {
          return LoginPage();  // If not authenticated, go to LoginPage
        }
      },
    );
  }
}
