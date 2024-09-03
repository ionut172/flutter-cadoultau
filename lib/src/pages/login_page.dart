import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:carousel_slider/carousel_slider.dart';

class LoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Verifică dacă documentul utilizatorului există și creează-l dacă nu
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid);
      DocumentSnapshot docSnapshot = await userDocRef.get();
      
      if (!docSnapshot.exists) {
        await userDocRef.set({
          'username': userCredential.user!.displayName ?? 'No Name',
          'email': userCredential.user!.email ?? '',
          'address': '',
          'phone': '',
          'favorite_people': [],
        });
      }

      // Verifică dacă utilizatorul are deja persoane favorite
      final userData = docSnapshot.data() as Map<String, dynamic>?; // Casting the data
      List<dynamic> favoritePeople = userData?['favorite_people'] ?? [];
      if (favoritePeople.isNotEmpty) {
        Navigator.of(context).pushReplacementNamed('MainPage');
      } else {
        Navigator.of(context).pushReplacementNamed('AddPersonPage');
      }
    } catch (e) {
      _showErrorDialog(context, 'Sign in with Apple failed. Please try again.');
      print(e);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential userCredential = await _auth.signInWithCredential(credential);

        DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid);
        DocumentSnapshot docSnapshot = await userDocRef.get();
        
        if (!docSnapshot.exists) {
          await userDocRef.set({
            'username': googleUser.displayName ?? 'No Name',
            'email': googleUser.email,
            'address': '',
            'phone': '',
            'favorite_people': [],
          });
        }

        final userData = docSnapshot.data() as Map<String, dynamic>?; // Casting the data
        List<dynamic> favoritePeople = userData?['favorite_people'] ?? [];

        if (favoritePeople.isNotEmpty) {
          Navigator.of(context).pushReplacementNamed('MainPage');
        } else {
          Navigator.of(context).pushReplacementNamed('AddPersonPage');
        }
      }
    } catch (e) {
      _showErrorDialog(context, 'Login with Google failed. Please try again.');
      print(e);
    }
  }

  Future<void> _loginWithEmailAndPassword(BuildContext context) async {
    try {
      final String email = emailController.text;
      final String password = passwordController.text;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid);
      DocumentSnapshot docSnapshot = await userDocRef.get();
      
      if (!docSnapshot.exists) {
        await userDocRef.set({
          'username': email,
          'email': email,
          'address': '',
          'phone': '',
          'favorite_people': [],
        });
      }

      final userData = docSnapshot.data() as Map<String, dynamic>?; // Casting the data
      List<dynamic> favoritePeople = userData?['favorite_people'] ?? [];

      if (favoritePeople.isNotEmpty) {
        Navigator.of(context).pushReplacementNamed('MainPage');
      } else {
        Navigator.of(context).pushReplacementNamed('AddPersonPage');
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException code: ${e.code}");
      _handleLoginError(context, e);
    } catch (e) {
      _showErrorDialog(context, 'An unknown error occurred. Please try again.');
      print(e);
    }
  }

  void _handleLoginError(BuildContext context, FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'user-disabled':
        message = 'This user has been disabled.';
        break;
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password':
        message = 'Incorrect password.';
        break;
      default:
        message = 'An unknown error occurred.';
        break;
    }
    _showErrorDialog(context, message);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items: [
                  'assets/slide_1.jpg',
                  'assets/slide_2.jpg',
                  'assets/slide_3.jpg'
                ].map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(i, fit: BoxFit.cover),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _loginWithEmailAndPassword(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('Login', style: TextStyle(fontSize: 18.0)),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _signInWithGoogle(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.grey),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      'assets/google_logo.png',
                      height: 24.0,
                    ),
                    SizedBox(width: 8.0),
                    Text('Login with Google', style: TextStyle(fontSize: 18.0)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _signInWithApple(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.apple, size: 24.0),
                    SizedBox(width: 8.0),
                    Text('Sign in with Apple', style: TextStyle(fontSize: 18.0)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('RegisterPage');
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('Register', style: TextStyle(fontSize: 18.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
