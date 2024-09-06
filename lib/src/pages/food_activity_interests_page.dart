import 'package:flutter/material.dart';
import 'package:cadoultau/src/pages/relationship_description_page.dart';

class FoodActivityInterestsPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String relation;
  final String birthdate;
  final String address;
  final String phone;
  
  final List<String> preferredProducts;

  FoodActivityInterestsPage({
    required this.firstName,
    required this.lastName,
    required this.relation,
    required this.birthdate,
    required this.address,
    required this.phone,
    required this.preferredProducts,
  });

  @override
  _FoodActivityInterestsPageState createState() => _FoodActivityInterestsPageState();
}

class _FoodActivityInterestsPageState extends State<FoodActivityInterestsPage> {
  final List<String> foodPreferences = ["Vegetarian", "Vegan", "Carnivor"];
  final List<String> activityPreferences = ["Fitness", "Yoga", "Reading"];
  final List<String> interestPreferences = ["Music", "Traveling", "Gaming"];

  List<String> selectedFoods = [];
  List<String> selectedActivities = [];
  List<String> selectedInterests = [];

  void _nextStep() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => RelationshipDescriptionPage(
        firstName: widget.firstName,
        lastName: widget.lastName,
        relation: widget.relation,
        birthdate: widget.birthdate,
        address: widget.address,
        phone: widget.phone,
        preferredProducts: widget.preferredProducts,
        foodPreferences: selectedFoods,
        activityPreferences: selectedActivities,
        interestPreferences: selectedInterests,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferințe'),
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
                'Preferințe Mâncare:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              ...foodPreferences.map((food) {
                return CheckboxListTile(
                  title: Text(food),
                  value: selectedFoods.contains(food),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedFoods.add(food);
                      } else {
                        selectedFoods.remove(food);
                      }
                    });
                  },
                );
              }).toList(),
              SizedBox(height: 10),
              Text(
                'Preferințe Activități:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              ...activityPreferences.map((activity) {
                return CheckboxListTile(
                  title: Text(activity),
                  value: selectedActivities.contains(activity),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedActivities.add(activity);
                      } else {
                        selectedActivities.remove(activity);
                      }
                    });
                  },
                );
              }).toList(),
              SizedBox(height: 10),
              Text(
                'Preferințe Interese:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              ...interestPreferences.map((interest) {
                return CheckboxListTile(
                  title: Text(interest),
                  value: selectedInterests.contains(interest),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedInterests.add(interest);
                      } else {
                        selectedInterests.remove(interest);
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
