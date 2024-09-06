import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cadoultau/src/pages/add_person_page.dart';

class SummaryPage extends StatefulWidget {
  final Map<String, dynamic> personData;

  SummaryPage({required this.personData});

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  List<Map<String, dynamic>> allPeopleData = [];

  @override
  void initState() {
    super.initState();
    // Adaugă prima persoană în listă la inițializare
    allPeopleData.add(widget.personData);
  }

  Future<void> _saveDataToFirebase(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Actualizează câmpul favorite_people cu toate persoanele adăugate
        await userDocRef.update({
          'favorite_people': FieldValue.arrayUnion(allPeopleData),
        });

        // Navighează la pagina principală după salvare
        Navigator.of(context).pushReplacementNamed('MainPage');
      } else {
        _showErrorDialog(context, 'User not authenticated');
      }
    } catch (e) {
      print(e);
      _showErrorDialog(context, 'Failed to save data. Please try again.');
    }
  }

  void _addAnotherRelation(BuildContext context) {
    // Navighează la pagina de adăugare a unei noi persoane
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddPersonPage(
        onPersonAdded: (newPersonData) {
          setState(() {
            allPeopleData.add(newPersonData);
          });
        },
      ),
    ));
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
        title: Text('Rezumat'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Informații despre persoană:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            for (var person in allPeopleData) ...[
              Text('Nume: ${person['basic_info']['firstName']} ${person['basic_info']['lastName']}'),
              Text('Relație: ${person['basic_info']['relation']}'),
              Text('Data nașterii: ${person['basic_info']['birthdate']}'),
              Text('Adresă: ${person['basic_info']['address']}'),
              Text('Telefon: ${person['basic_info']['phone']}'),
              SizedBox(height: 10),
              Text(
                'Preferințe Produse:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              for (var product in person['product_preferences']) Text('- $product'),
              SizedBox(height: 10),
              Text(
                'Preferințe Alimentare și Activități:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              for (var food in person['food_activity']['foodPreferences']) Text('- $food'),
              for (var activity in person['food_activity']['activityPreferences']) Text('- $activity'),
              for (var interest in person['food_activity']['interestPreferences']) Text('- $interest'),
              SizedBox(height: 10),
              Text(
                'Descrierea Relației:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(person['relationship_description']['description']),
              Divider(height: 20, thickness: 2),
            ],
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => _addAnotherRelation(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontSize: 16.0),
                ),
                child: Text('Adaugă o altă relație'),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () => _saveDataToFirebase(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontSize: 16.0),
                ),
                child: Text('Finalizează'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
