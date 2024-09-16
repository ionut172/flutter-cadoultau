import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cadoultau/src/pages/product_preferences_page.dart';

class AddPersonPage extends StatefulWidget {
  final Function(Map<String, dynamic>)? onPersonAdded;

  AddPersonPage({this.onPersonAdded});

  @override
  _AddPersonPageState createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController allTimeDateController = TextEditingController(); // Controler pentru allTimeDate

  String? selectedRelation;
  String? selectedSex;

  final List<String> relations = ["Soție", "Iubită", "Mamă", "Tată", "Iubit"];
  final List<String> sexes = ["Masculin", "Feminin", "Altceva"];

  // Funcția capitalizează fiecare cuvânt și elimină spațiile libere
  String capitalize(String value) {
    if (value.isEmpty) return value;
    return value.trim().split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      } else {
        return '';
      }
    }).join(' ');
  }
  
  // Funcția de validare și trecere la pasul următor
  void _nextStep() {
  if (selectedRelation != null &&
      selectedSex != null &&
      firstNameController.text.isNotEmpty &&
      lastNameController.text.isNotEmpty &&
      birthdateController.text.isNotEmpty &&
      addressController.text.isNotEmpty &&
      phoneController.text.isNotEmpty &&
      allTimeDateController.text.isNotEmpty) { // Verificăm dacă toate câmpurile sunt completate

    // Procesăm prenumele și numele pentru a le capitaliza
    String firstName = capitalize(firstNameController.text);
    String lastName = capitalize(lastNameController.text);

    // Procesăm adresa și telefonul
    String address = addressController.text.trim();
    String phone = phoneController.text.trim();
    String allTimeDate = allTimeDateController.text.trim(); // Data de când petrec timp împreună

    // Creează un obiect care conține toate informațiile
    Map<String, dynamic> personData = {
      'basic_info': {
        'relation': selectedRelation,
        'firstName': firstName,
        'lastName': lastName,
        'birthdate': birthdateController.text,
        'address': address,
        'phone': phone,
        'sex': selectedSex,
        'allTimeDate': allTimeDateController.text,
      }
    };

    // Verificăm dacă este definit un callback pentru adăugarea persoanei
    if (widget.onPersonAdded != null) {
      widget.onPersonAdded!(personData);
    }

    // Navigăm la pagina următoare
    Navigator.of(context).push(MaterialPageRoute(
  builder: (context) => ProductPreferencesPage(
    firstName: firstName,
    lastName: lastName,
    relation: selectedRelation!,
    birthdate: birthdateController.text,
    address: address,
    phone: phone,
    sex: selectedSex!,
    allTimeDate: allTimeDateController.text, // Trebuie să adăugăm corect acest parametru
  ),
));
  } else {
    _showErrorDialog('Toate câmpurile sunt obligatorii.');
  }
}


  // Afișează un dialog de eroare
  void _showErrorDialog(String message) {
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
      appBar: AppBar(
        title: Text('Adăuga Persoană'),
        backgroundColor: Colors.deepPurple,
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
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Sex',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: sexes.map((sex) {
                  return DropdownMenuItem(
                    value: sex,
                    child: Text(sex),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSex = value as String?;
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
                controller: allTimeDateController, // Câmpul pentru prima întâlnire
                decoration: InputDecoration(
                  labelText: 'Prima întâlnire',
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
                      allTimeDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
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
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 16.0),
                  ),
                  child: Text('Următorul Pas'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
