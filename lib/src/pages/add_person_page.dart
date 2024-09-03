import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPersonPage extends StatefulWidget {
  @override
  _AddPersonPageState createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> people = [];

  final List<String> relations = ["Soție", "Iubită", "Mamă", "Tată"];
  final List<String> productCategories = ["Parfumuri", "Bijuterii", "Cărți", "Gadgeturi"];

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedRelation;
  String? selectedProductCategory;

  void _addAndSavePerson(BuildContext context) async {
    if (selectedRelation != null &&
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        birthdateController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        selectedProductCategory != null) {
      
      people.add({
        'relation': selectedRelation,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'birthdate': DateTime.parse(birthdateController.text).toIso8601String(),
        'address': addressController.text,
        'phone': phoneController.text,
        'preferredProduct': selectedProductCategory,
      });

      try {
        User? user = _auth.currentUser;
        if (user != null) {
          DocumentReference userDocRef = _firestore.collection('users').doc(user.uid);

          DocumentSnapshot docSnapshot = await userDocRef.get();
          if (!docSnapshot.exists) {
            await userDocRef.set({
              'username': user.displayName ?? user.email ?? 'No Name',
              'email': user.email,
              'address': '',
              'phone': '',
              'favorite_people': [],
            });
          }

          if (people.isNotEmpty) {
            await userDocRef.update({
              'favorite_people': FieldValue.arrayUnion(people),
            });

            _showSuccessMessage(context);
          }
        }
      } catch (e) {
        print(e);
        _showErrorDialog(context, 'Failed to save person. Please try again.');
      }
    } else {
      _showErrorDialog(context, 'Toate câmpurile sunt obligatorii.');
    }
  }

  void _showSuccessMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Succes!'),
        content: Text('Persoana a fost înregistrată cu succes.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('MainPage');
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
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
      appBar: AppBar(
        title: Text('Adăuga Persoană'),
        backgroundColor: Colors.deepPurple, // Schimbă culoarea AppBar-ului
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Completează detaliile persoanei:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Relație',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                items: relations.map((relation) {
                  return DropdownMenuItem(
                    value: relation,
                    child: Text(relation),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRelation = value as String?;
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'Prenume',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Nume',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: birthdateController,
                decoration: InputDecoration(
                  labelText: 'Data nașterii',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      birthdateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
                readOnly: true,
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
              SizedBox(height: 10),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Produse Preferate',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                items: productCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProductCategory = value as String?;
                  });
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _addAndSavePerson(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white, // Asigură că textul este alb
                    textStyle: TextStyle(fontSize: 16.0),
                  ),
                  child: Text('Salvează'),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('MainPage'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white, // Asigură că textul este alb
                    textStyle: TextStyle(fontSize: 16.0),
                  ),
                  child: Text('Continua fără a adăuga persoane'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
