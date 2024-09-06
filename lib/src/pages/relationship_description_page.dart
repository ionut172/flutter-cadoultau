import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cadoultau/src/pages/summary_page.dart';

class RelationshipDescriptionPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String relation;
  final String birthdate;
  final String address;
  final String phone;
  final List<String> preferredProducts;
  final List<String> foodPreferences;
  final List<String> activityPreferences;
  final List<String> interestPreferences;
  

  RelationshipDescriptionPage({
    required this.firstName,
    required this.lastName,
    required this.relation,
    required this.birthdate,
    required this.address,
    required this.phone,
    required this.preferredProducts,
    required this.foodPreferences,
    required this.activityPreferences,
    required this.interestPreferences,
  });

  @override
  _RelationshipDescriptionPageState createState() => _RelationshipDescriptionPageState();
}

class _RelationshipDescriptionPageState extends State<RelationshipDescriptionPage> {
  final TextEditingController descriptionController = TextEditingController();

  void _finalStep(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        Map<String, dynamic> personData = {
          'basic_info': {
            'relation': widget.relation,
            'firstName': widget.firstName,
            'lastName': widget.lastName,
            'birthdate': widget.birthdate,
            'address': widget.address,
            'phone': widget.phone,
          },
          'product_preferences': widget.preferredProducts,
          'food_activity': {
            'foodPreferences': widget.foodPreferences,
            'activityPreferences': widget.activityPreferences,
            'interestPreferences': widget.interestPreferences,
          },
          'relationship_description': {
            'description': descriptionController.text,
          },
        };

        await userDocRef.update({
          'favorite_people': FieldValue.arrayUnion([personData]),
        });

        // Navighează la pagina de rezumat
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SummaryPage(personData: personData),
          ),
        );
      }
    } catch (e) {
      print(e);
      _showErrorDialog(context, 'Failed to save person. Please try again.');
    }
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
        title: Text('Descrierea Relației'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();  // Se întoarce la pagina anterioară
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Descrie relația:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descriere',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _finalStep(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 16.0),
                  ),
                  child: Text('Finalizează și Salvează'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
