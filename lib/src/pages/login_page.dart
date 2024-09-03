import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:carousel_slider/carousel_slider.dart';

class LoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);
        Navigator.of(context).pushReplacementNamed('MainPage');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loginWithEmailAndPassword(BuildContext context) async {
    try {
      final String email = emailController.text;
      final String password = passwordController.text;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.of(context).pushReplacementNamed('MainPage');
    } catch (e) {
      print(e);
    }
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
                  'assets/slide_1.jpg',  // Replace with actual asset paths
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
                        ),
                        child: Image.asset(i, fit: BoxFit.cover),
                      );
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _loginWithEmailAndPassword(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                ),
                child: Text('Login'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _signInWithGoogle(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      'assets/google_logo.png',  // Ensure this image exists in your assets folder
                      height: 24.0,
                    ),
                    SizedBox(width: 8.0),
                    Text('Login with Google'),
                  ],
                ),
              ),
              SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('RegisterPage');
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
