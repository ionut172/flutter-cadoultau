import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    final String email = emailController.text;
    final String password = passwordController.text;
    final String username = usernameController.text;
    final String address = addressController.text;
    final String phone = phoneController.text;

    if (username.length < 4) {
      _showErrorDialog(context, 'Username trebuie să aibă cel puțin 4 caractere.');
      return;
    }

    if (password.length < 6) {
      _showErrorDialog(context, 'Parola trebuie să aibă cel puțin 6 caractere.');
      return;
    }

    try {
      // Creare utilizator nou cu email și parolă
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Salvare informații utilizator în Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'address': address,
        'phone': phone,
        'favorite_people': [],  // Inițializarea unei liste goale pentru favorite
      });

      Navigator.of(context).pushReplacementNamed('LoginPage');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Adresa de email este deja utilizată de un alt cont.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Adresa de email nu este validă.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Parola este prea slabă. Alegeți o parolă mai puternică.';
      } else {
        errorMessage = 'Eroare la înregistrare. Vă rugăm să verificați datele și să încercați din nou.';
      }
      _showErrorDialog(context, errorMessage);
    } catch (e) {
      _showErrorDialog(context, 'A apărut o eroare neașteptată. Vă rugăm să încercați din nou.');
      print(e);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eroare'),
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
      appBar: AppBar(title: Text('Înregistrare')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam.',
                style: TextStyle(fontSize: 16.0),
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
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Parolă',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Adresă',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Număr de Telefon',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _register(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white, // Asigură că textul este alb
                  ),
                  child: Text('Înregistrare', style: TextStyle(fontSize: 18.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
