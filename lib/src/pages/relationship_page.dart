import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RelationshipPage extends StatefulWidget {
  @override
  _RelationshipPageState createState() => _RelationshipPageState();
}

class _RelationshipPageState extends State<RelationshipPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Inițializarea controlerelor
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _relationshipDescriptionController = TextEditingController();
  final TextEditingController _allTimeDateController = TextEditingController();

  // Liste de preferințe disponibile
  final List<String> productCategories = ["Parfumuri", "Bijuterii", "Cărți", "Gadgeturi"];
  final List<String> foodPreferencesList = ["Vegetarian", "Vegan", "Carnivor"];
  final List<String> activityPreferencesList = ["Fitness", "Yoga", "Reading"];
  final List<String> interestPreferencesList = ["Music", "Traveling", "Gaming"];
  final List<String> relations = ["Soție", "Iubită", "Mamă", "Tată"];

  // Liste de preferințe selectate
  List<String> selectedProducts = [];
  List<String> selectedFoodPreferences = [];
  List<String> selectedActivityPreferences = [];
  List<String> selectedInterestPreferences = [];

  // Selected values for dropdowns
  String? selectedRelation;

  // Variabila pentru checkbox-ul de detalii suplimentare
  bool _extraDetailsChecked = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    _allTimeDateController.dispose();
    _relationshipDescriptionController.dispose();
    super.dispose();
  }

  // Funcție pentru eliminarea spațiilor libere și capitalizarea fiecărui cuvânt
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Persoanele Favorite'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCreateOrUpdateDialog(),
          ),
        ],
      ),
      body: _buildFavoritePeopleList(),
    );
  }

  Widget _buildFavoritePeopleList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection('users').doc(currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('A apărut o eroare la încărcarea datelor.'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('Nu există date disponibile.'));
        }

        Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> favoritePeople = userData['favorite_people'] ?? [];

        if (favoritePeople.isEmpty) {
          return Center(child: Text('Nu ai adăugat nicio persoană favorită.'));
        }

        return ListView.builder(
          itemCount: favoritePeople.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> person = favoritePeople[index]['basic_info'];

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text('${person['firstName']} ${person['lastName']}'),
                subtitle: Text(person['relation']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showCreateOrUpdateDialog(
                        personIndex: index,
                        initialData: favoritePeople[index],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePerson(index),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deletePerson(int index) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();

    if (confirmDelete) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        DocumentReference userDocRef = firestore.collection('users').doc(user!.uid);

        DocumentSnapshot userDoc = await userDocRef.get();
        List<dynamic> favoritePeople = userDoc['favorite_people'];

        favoritePeople.removeAt(index);

        await userDocRef.update({'favorite_people': favoritePeople});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Persoana a fost ștearsă.')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Eroare la ștergerea persoanei.')));
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmare ștergere'),
          content: Text('Sunteți sigur că doriți să ștergeți această persoană?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Nu'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Da'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _createPerson() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Utilizator neautentificat.')));
        return;
      }
      DocumentReference userDocRef = firestore.collection('users').doc(user.uid);

      DocumentSnapshot userDoc = await userDocRef.get();
      List<dynamic> favoritePeople = userDoc['favorite_people'] ?? [];

      // Procesăm numele și prenumele folosind capitalize și eliminăm spațiile
      String firstName = capitalize(_firstNameController.text);
      String lastName = capitalize(_lastNameController.text);
      String address = _addressController.text.trim();
      String phone = _phoneController.text.trim();

      favoritePeople.add({
        'basic_info': {
          'firstName': firstName,
          'lastName': lastName,
          'relation': selectedRelation,
          'address': address,
          'phone': phone,
          'birthdate': _birthdateController.text.trim(),
          'allTimeDate': _allTimeDateController.text.trim(), // Adăugăm data petrecerii timpului
          'extraDetails': _extraDetailsChecked, // Detalii suplimentare
        },
        'product_preferences': selectedProducts,
        'food_activity': {
          'foodPreferences': selectedFoodPreferences,
          'activityPreferences': selectedActivityPreferences,
          'interestPreferences': selectedInterestPreferences,
        },
        'relationship_description': {
          'description': _relationshipDescriptionController.text.trim(),
        
        },
      });

      await userDocRef.update({'favorite_people': favoritePeople});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Persoana a fost adăugată.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Eroare la adăugarea persoanei.')));
    }
  }

  Future<void> _updatePerson(int personIndex) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Utilizator neautentificat.')));
        return;
      }
      DocumentReference userDocRef = firestore.collection('users').doc(user.uid);

      DocumentSnapshot userDoc = await userDocRef.get();
      List<dynamic> favoritePeople = userDoc['favorite_people'];

      // Procesăm numele și prenumele folosind capitalize și eliminăm spațiile
      String firstName = capitalize(_firstNameController.text);
      String lastName = capitalize(_lastNameController.text);
      String address = _addressController.text.trim();
      String phone = _phoneController.text.trim();

      favoritePeople[personIndex] = {
        'basic_info': {
          'firstName': firstName,
          'lastName': lastName,
          'relation': selectedRelation,
          'address': address,
          'phone': phone,
          'birthdate': _birthdateController.text.trim(),
          'allTimeDate': _allTimeDateController.text.trim(), // Adăugăm data petrecerii timpului
           'extraDetails': _extraDetailsChecked, // Detalii suplimentare
        },
        'product_preferences': selectedProducts,
        'food_activity': {
          'foodPreferences': selectedFoodPreferences,
          'activityPreferences': selectedActivityPreferences,
          'interestPreferences': selectedInterestPreferences,
        },
        'relationship_description': {
          'description': _relationshipDescriptionController.text.trim(),
         
        },
      };

      await userDocRef.update({'favorite_people': favoritePeople});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Persoana a fost actualizată.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Eroare la actualizarea persoanei.')));
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ro', 'RO'),
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _showCreateOrUpdateDialog({int? personIndex, Map<String, dynamic>? initialData}) async {
    setState(() {
      if (initialData != null) {
        _firstNameController.text = initialData['basic_info']['firstName'] ?? '';
        _lastNameController.text = initialData['basic_info']['lastName'] ?? '';
        selectedRelation = initialData['basic_info']['relation'];
        _addressController.text = initialData['basic_info']['address'] ?? '';
        _phoneController.text = initialData['basic_info']['phone'] ?? '';
        DateTime? birthdate = DateTime.tryParse(initialData['basic_info']['birthdate'] ?? '');
        _birthdateController.text = birthdate != null ? DateFormat('yyyy-MM-dd').format(birthdate) : '';
        DateTime? allTimeDate = DateTime.tryParse(initialData['basic_info']['allTimeDate'] ?? '');
        _allTimeDateController.text = allTimeDate != null ? DateFormat('yyyy-MM-dd').format(allTimeDate) : '';
        selectedProducts = List<String>.from(initialData['product_preferences'] ?? []);
        selectedFoodPreferences = List<String>.from(initialData['food_activity']['foodPreferences'] ?? []);
        selectedActivityPreferences = List<String>.from(initialData['food_activity']['activityPreferences'] ?? []);
        selectedInterestPreferences = List<String>.from(initialData['food_activity']['interestPreferences'] ?? []);
        _relationshipDescriptionController.text = initialData['relationship_description']['description'] ?? '';
        _extraDetailsChecked = initialData['basic_info']['extraDetails'] ?? false;
      } else {
        _firstNameController.clear();
        _lastNameController.clear();
        selectedRelation = null;
        _addressController.clear();
        _phoneController.clear();
        _birthdateController.clear();
        _allTimeDateController.clear();
        selectedProducts.clear();
        selectedFoodPreferences.clear();
        selectedActivityPreferences.clear();
        selectedInterestPreferences.clear();
        _relationshipDescriptionController.clear();
        _extraDetailsChecked = false;
      }
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            title: Center(
              child: Text(
                personIndex == null ? 'Adaugă persoană favorită' : 'Editează persoana favorită',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(_firstNameController, 'Prenume', Icons.person),
                  SizedBox(height: 10),
                  _buildTextField(_lastNameController, 'Nume', Icons.person_outline),
                  SizedBox(height: 10),
                  _buildDropdownField('Relație', selectedRelation, relations, setDialogState),
                  SizedBox(height: 10),
                  _buildTextField(_addressController, 'Adresă', Icons.location_on),
                  SizedBox(height: 10),
                  _buildTextField(_phoneController, 'Telefon', Icons.phone),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _selectDate(context, _birthdateController),
                    child: AbsorbPointer(
                      child: _buildTextField(_birthdateController, 'Data nașterii', Icons.calendar_today),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _selectDate(context, _allTimeDateController),
                    child: AbsorbPointer(
                      child: _buildTextField(_allTimeDateController, 'Prima întâlnire :)', Icons.access_time),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Checkbox pentru detalii suplimentare
                  CheckboxListTile(
                    title: Text('Vreau detalii extra despre informații'),
                    value: _extraDetailsChecked,
                    onChanged: (bool? value) {
                      setDialogState(() {
                        _extraDetailsChecked = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  
                  SizedBox(height: 15),
                  _buildCheckboxList('Preferințe Produse', productCategories, selectedProducts, setDialogState),
                  _buildCheckboxList('Preferințe Mâncare', foodPreferencesList, selectedFoodPreferences, setDialogState),
                  _buildCheckboxList('Preferințe Activități', activityPreferencesList, selectedActivityPreferences, setDialogState),
                  _buildCheckboxList('Preferințe Interese', interestPreferencesList, selectedInterestPreferences, setDialogState),
                  SizedBox(height: 10),
                  _buildTextField(_relationshipDescriptionController, 'Descriere relație', Icons.description),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Anulează'),
                style: TextButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_validateFields()) {
                    if (personIndex == null) {
                      await _createPerson();
                    } else {
                      await _updatePerson(personIndex);
                    }
                    Navigator.of(context).pop();
                  }
                },
                child: Text(personIndex == null ? 'Creează' : 'Actualizează'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _validateFields() {
    String errorMessage = '';

    if (_firstNameController.text.isEmpty) {
      errorMessage += 'Prenumele este obligatoriu.\n';
    }
    if (_lastNameController.text.isEmpty) {
      errorMessage += 'Numele este obligatoriu.\n';
    }
    if (selectedRelation == null) {
      errorMessage += 'Relația este obligatorie.\n';
    }
    if (_addressController.text.isEmpty) {
      errorMessage += 'Adresa este obligatorie.\n';
    }
    if (_phoneController.text.isEmpty) {
      errorMessage += 'Numărul de telefon este obligatoriu.\n';
    }
    if (_birthdateController.text.isEmpty) {
      errorMessage += 'Data nașterii este obligatorie.\n';
    }
    if (_allTimeDateController.text.isEmpty) {
      errorMessage += 'Prima întâlnire este obligatorie :) \n';
    }

    if (errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      return false;
    }

    return true;
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> options, Function setDialogState) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: (newValue) {
        setDialogState(() {
          selectedRelation = newValue;
        });
      },
    );
  }

  Widget _buildCheckboxList(String title, List<String> options, List<String> selectedValues, Function setDialogState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        ...options.map((option) {
          return CheckboxListTile(
            title: Text(option),
            value: selectedValues.contains(option),
            onChanged: (bool? value) {
              setDialogState(() {
                if (value == true) {
                  selectedValues.add(option);
                } else {
                  selectedValues.remove(option);
                }
              });
            },
          );
        }).toList(),
      ],
    );
  }
}
