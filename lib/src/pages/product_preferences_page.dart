import 'package:flutter/material.dart';
import 'package:cadoultau/src/pages/food_activity_interests_page.dart';
class ProductPreferencesPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String relation;
  final String birthdate;
  final String address;
  final String phone;
  final String sex; // Adaugă acest parametru

  ProductPreferencesPage({
    required this.firstName,
    required this.lastName,
    required this.relation,
    required this.birthdate,
    required this.address,
    required this.phone,
    required this.sex, // Adaugă acest parametru în constructor
  });

  @override
  _ProductPreferencesPageState createState() => _ProductPreferencesPageState();
}

class _ProductPreferencesPageState extends State<ProductPreferencesPage> {
  final List<String> productCategories = ["Parfumuri", "Bijuterii", "Cărți", "Gadgeturi"];
  List<String> selectedProducts = [];

  void _nextStep() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FoodActivityInterestsPage(
        firstName: widget.firstName,
        lastName: widget.lastName,
        relation: widget.relation,
        birthdate: widget.birthdate,
        address: widget.address,
        phone: widget.phone,
        preferredProducts: selectedProducts,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferințe Produse'),
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
                'Selectează produsele preferate:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              SizedBox(height: 20),
              ...productCategories.map((product) {
                return CheckboxListTile(
                  title: Text(product),
                  value: selectedProducts.contains(product),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedProducts.add(product);
                      } else {
                        selectedProducts.remove(product);
                      }
                    });
                  },
                );
              }).toList(),
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
