import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cadoultau/src/widgets/event_card.dart';
import 'package:cadoultau/src/pages/login_page.dart';

class EventList extends StatelessWidget {
  User? currentUser = FirebaseAuth.instance.currentUser;

  // Definim zilele de onomastică pentru numele cunoscute
  final Map<String, DateTime> nameDays = {
  // Sfinții mari și sărbătorile principale
  "Andrei": DateTime(DateTime.now().year, 11, 30),
  "Ion": DateTime(DateTime.now().year, 1, 7),
  "Ionut": DateTime(DateTime.now().year, 1, 7), // Derivat de la Ion
  "Ioana": DateTime(DateTime.now().year, 1, 7),
  "Maria": DateTime(DateTime.now().year, 8, 15), // Adormirea Maicii Domnului
  "Gheorghe": DateTime(DateTime.now().year, 4, 23),
  "Nicolae": DateTime(DateTime.now().year, 12, 6),
  "Stefan": DateTime(DateTime.now().year, 12, 27),
  
  // Adăugiri suplimentare
  "Petru": DateTime(DateTime.now().year, 6, 29),
  "Pavel": DateTime(DateTime.now().year, 6, 29),
  "Ana": DateTime(DateTime.now().year, 7, 25),
  "Elena": DateTime(DateTime.now().year, 5, 21),
  "Constantin": DateTime(DateTime.now().year, 5, 21),
  "Dumitru": DateTime(DateTime.now().year, 10, 26),
  "Ilie": DateTime(DateTime.now().year, 7, 20),
  "Cristina": DateTime(DateTime.now().year, 7, 24),
  "Daniel": DateTime(DateTime.now().year, 12, 17),
  "Gabriel": DateTime(DateTime.now().year, 3, 26),
  "Gavril": DateTime(DateTime.now().year, 3, 26),
  "Valentin": DateTime(DateTime.now().year, 2, 14),
  "Alexandru": DateTime(DateTime.now().year, 8, 30),
  "Alexandra": DateTime(DateTime.now().year, 8, 30),
  "Adrian": DateTime(DateTime.now().year, 3, 26),
  "Valeria": DateTime(DateTime.now().year, 6, 7),
  "Eugen": DateTime(DateTime.now().year, 7, 13),
  "Eugenia": DateTime(DateTime.now().year, 7, 13),
  
  // Nume derivate și abrevieri
  "Vasile": DateTime(DateTime.now().year, 1, 1),
  "Valeriu": DateTime(DateTime.now().year, 2, 14),
  "Teodor": DateTime(DateTime.now().year, 2, 17),
  "Teodora": DateTime(DateTime.now().year, 2, 17),
  "Sofia": DateTime(DateTime.now().year, 9, 17),
  "Silvia": DateTime(DateTime.now().year, 10, 1),
  "Sebastian": DateTime(DateTime.now().year, 12, 18),
  "Radu": DateTime(DateTime.now().year, 7, 21),
  "Lucian": DateTime(DateTime.now().year, 10, 26),
  "Luca": DateTime(DateTime.now().year, 10, 18),
  "Mihai": DateTime(DateTime.now().year, 11, 8), // Sf. Arhanghel Mihail
  "Gavril": DateTime(DateTime.now().year, 11, 8), // Sf. Arhanghel Gavril

  // Alte nume importante
  "Florin": DateTime(DateTime.now().year, 4, 10),
  "Florina": DateTime(DateTime.now().year, 4, 10),
  "Marius": DateTime(DateTime.now().year, 1, 19),
  "Adela": DateTime(DateTime.now().year, 12, 24),
  "Emil": DateTime(DateTime.now().year, 12, 18),
  "Sergiu": DateTime(DateTime.now().year, 10, 7),
  "Viorica": DateTime(DateTime.now().year, 6, 14),
  "Zoe": DateTime(DateTime.now().year, 9, 17),
  "Ana-Maria": DateTime(DateTime.now().year, 8, 15), // Derivat de la Maria
  "Cristian": DateTime(DateTime.now().year, 12, 25), // Crăciun, asociat cu nașterea lui Iisus
};


  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
       if (currentUser == null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Nu sunteți autentificat.'),
          SizedBox(height: 20), // Spațiu între text și buton
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: Text(
              'Loghează-te',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Eroare la încărcarea datelor'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('Nu există date disponibile'));
        }

        Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> favoritePeople = userData['favorite_people'] ?? [];

        if (favoritePeople.isEmpty) {
          return Center(child: Text('Nu există persoane favorite'));
        }

        favoritePeople.sort((a, b) {
          DateTime birthdateA = _getBirthdate(a['basic_info']);
          DateTime birthdateB = _getBirthdate(b['basic_info']);
          return daysUntilNextBirthday(birthdateA).compareTo(daysUntilNextBirthday(birthdateB));
        });

        return CarouselSlider(
          options: CarouselOptions(
            height: 450.0,
            enlargeCenterPage: true,
            viewportFraction: 0.6,
            scrollDirection: Axis.vertical,
            autoPlayAnimationDuration: Duration(milliseconds: 800),
          ),
          items: favoritePeople.map((person) {
            if (person.containsKey('basic_info')) {
              Map<String, dynamic> personData = person['basic_info'] ?? {};
              return EventCard(personData, nameDays); // Transmitem și map-ul pentru onomastică
            }
            return Container();
          }).toList(),
        );
      },
    );
  }

  DateTime _getBirthdate(Map<String, dynamic> personData) {
    DateTime birthdate;
    try {
      if (personData['birthdate'] is Timestamp) {
        birthdate = (personData['birthdate'] as Timestamp).toDate();
      } else {
        birthdate = DateTime.parse(personData['birthdate']);
      }
    } catch (e) {
      birthdate = DateTime.now();
    }
    return birthdate;
  }

  int daysUntilNextBirthday(DateTime birthdate) {
    DateTime now = DateTime.now();
    DateTime nextBirthday = DateTime(now.year, birthdate.month, birthdate.day);

    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthdate.month, birthdate.day);
    }

    return nextBirthday.difference(now).inDays;
  }
}
