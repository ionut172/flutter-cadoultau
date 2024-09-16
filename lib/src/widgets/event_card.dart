import 'package:flutter/material.dart';
import 'package:cadoultau/src/pages/gift_page.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> personData;
  final Map<String, DateTime> nameDays;
    
  EventCard(this.personData, this.nameDays);

  @override
  Widget build(BuildContext context) {
    String firstName = personData['firstName'] ?? 'N/A';  // Luăm prenumele (firstName) al persoanei
    String lastName = personData['lastName'] ?? 'N/A';
    String relation = personData['relation'] ?? 'Relație necunoscută';
    DateTime birthdate = DateTime.parse(personData['birthdate']); // Luăm data nașterii
    DateTime allTimeDate = DateTime.parse(personData['allTimeDate']); // Luăm data de când sunt împreună
    DateTime now = DateTime.now();
    int daysUntilBirthday = daysUntilNextBirthday(birthdate);
    int yearsTogether = now.year - allTimeDate.year;
    int monthsTogether = now.month - allTimeDate.month;
    int daysTogether = now.day - allTimeDate.day;
    
    
    if (daysTogether < 0) {
      monthsTogether--;
      daysTogether += DateTime(now.year, now.month, 0).day; // Numărul de zile din luna anterioară
    }

    if (monthsTogether < 0) {
      yearsTogether--;
      monthsTogether += 12;
    }
    
    // Calculăm zilele până la onomastică, doar dacă există
    int daysUntilNameDay = daysUntilNextNameDay(firstName);

        // Verificăm dacă există câmpul `extraDetails` și dacă este `true`
        
    bool extraDetails = personData['extraDetails'] ?? false;

    return Container(
  margin: EdgeInsets.symmetric(horizontal: 8),
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        spreadRadius: 3,
        blurRadius: 5,
      ),
    ],
  ),
  child: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$firstName $lastName',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          '$relation',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Aniversare în: $daysUntilBirthday zile',
          style: TextStyle(fontSize: 16, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        // Verificăm dacă există o onomastică pentru acest prenume
        if (daysUntilNameDay != -1)
          Column(
            children: [
              SizedBox(height: 8),
              Text(
                'Onomastica în: $daysUntilNameDay zile',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        SizedBox(height: 8),
        Text(
          'Împreună de: $yearsTogether ani - $monthsTogether luni - $daysTogether zile',
          style: TextStyle(fontSize: 16, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        
        // Afișăm detalii suplimentare dacă `extraDetails` este `true`
        if (extraDetails)
          Column(
            children: [
              SizedBox(height: 8),
              Text(
                'Detalii extra: Împreună de $yearsTogether ani și $monthsTogether luni',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Prima întâlnire a fost pe ${DateFormat('yyyy-MM-dd').format(allTimeDate)}',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        SizedBox(height: 15),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GiftPage()), // Navigăm la GiftPage
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          ),
          child: Text(
            'Trimite un cadou',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    ),
  ),
);

  }

  // Funcția pentru calculul zilelor rămase până la onomastica bazată pe firstName
  int daysUntilNextNameDay(String firstName) {
    if (!nameDays.containsKey(firstName)) return -1; // Dacă nu există onomastica, returnăm -1

    DateTime now = DateTime.now();
    DateTime nameDay = nameDays[firstName]!;

    // Verificăm dacă onomastica din acest an a trecut deja
    if (nameDay.isBefore(now)) {
      nameDay = DateTime(now.year + 1, nameDay.month, nameDay.day); // Dacă a trecut, setăm pentru anul următor
    }

    return nameDay.difference(now).inDays; // Returnăm diferența în zile
  }

  // Funcția pentru calculul zilelor până la următoarea aniversare
  int daysUntilNextBirthday(DateTime birthdate) {
    DateTime now = DateTime.now();
    DateTime nextBirthday = DateTime(now.year, birthdate.month, birthdate.day);

    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthdate.month, birthdate.day);
    }

    return nextBirthday.difference(now).inDays;
  }
}
