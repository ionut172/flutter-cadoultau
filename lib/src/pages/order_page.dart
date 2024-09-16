import 'dart:convert'; // Import pentru JSON
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:http/http.dart' as http; // Import pentru request HTTP
import 'package:stripe_payment/stripe_payment.dart'; // Import Stripe Payment
import '../model/order.dart' as model;


class OrderPage extends StatefulWidget {
  final double totalAmount;
  
  OrderPage({required this.totalAmount});  // Adăugăm totalAmount ca parametru
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String phoneNumber = '';
  String? selectedPerson;
  String observations = ''; // Câmp pentru observații

  @override
  void initState() {
    super.initState();
    // Inițializează Stripe cu cheia publicabilă
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: "pk_test_51NOGeVCp1hoguf4ztqRYU6hccgD11U5aTcKIGR9PEZJLr6FlLfOyjPTF9MndqIRIsFhbkcvKLE5PBHZlZYCAGvOf00NazGxIbq", // Înlocuiește cu cheia ta Stripe publicabilă
        androidPayMode: 'test',
      ),
    );
  }

  void _populateFields(Map<String, dynamic> personData) {
    Map<String, dynamic> basicInfo = personData['basic_info'] ?? {};
    setState(() {
      name = (basicInfo['firstName'] ?? 'Necunoscut') + ' ' + (basicInfo['lastName'] ?? 'Necunoscut');
      address = basicInfo['address'] ?? 'Adresă necunoscută';
      phoneNumber = basicInfo['phone'] ?? 'Număr necunoscut';
    });
  }

  Future<void> _submitOrderAndPay() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    try {
      // Obține emailul utilizatorului autentificat
       User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('Utilizator neautentificat');
        }
        Uri url = Uri.parse('https://a207-2a02-2f09-d20b-8900-49da-80a-4383-dcc1.ngrok-free.app/create-payment-intent');
        final response = await http.post(
          url, // Aici trecem URL-ul definit anterior
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'amount': (widget.totalAmount * 100).toInt(), // Folosește widget.totalAmount
            'currency': 'ron',
          }),
        );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final clientSecret = jsonResponse['clientSecret'];

        // Pasul 2: Inițierea plății cu Stripe folosind client_secret
        await StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest()).then((paymentMethod) async {
          final paymentIntentResult = await StripePayment.confirmPaymentIntent(
            PaymentIntent(
              clientSecret: clientSecret,
              paymentMethodId: paymentMethod.id,
            ),
          );

          if (paymentIntentResult.status == 'succeeded') {
            // Pasul 3: După succesul plății, salvează comanda în Firestore
            model.Order newOrder = model.Order(
              name: name,
              address: address,
              phoneNumber: phoneNumber,
              selectedPersonId: selectedPerson,
              observations: observations,
              userEmail: currentUser.email!, // Include emailul utilizatorului
            );

            await firestore.FirebaseFirestore.instance.collection('orders').add(newOrder.toMap());

            // Afișează mesajul de succes
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Plata și comanda au fost realizate cu succes!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            throw Exception('Plata nu a fost finalizată.');
          }
        });
      } else {
        throw Exception('Eroare la crearea PaymentIntent.');
      }
    } catch (e) {
      // Gestionează erorile la plata cu Stripe
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plata a eșuat: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalii Livrare', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: StreamBuilder<firestore.DocumentSnapshot>(
                    stream: firestore.FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      List<dynamic> favoritePeople = snapshot.data?['favorite_people'] ?? [];

                      if (favoritePeople.isEmpty) {
                        return Text('Nu aveți persoane favorite.');
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (selectedPerson == null && favoritePeople.isNotEmpty) {
                          setState(() {
                          selectedPerson = favoritePeople.first['basic_info']['firstName'] + ' ' + favoritePeople.first['basic_info']['lastName'];
                            _populateFields(favoritePeople.first);
                          });
                        }
                      });

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Selectează persoana',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedPerson,
                        items: favoritePeople.map<DropdownMenuItem<String>>((person) {
                          Map<String, dynamic> basicInfo = person['basic_info'] ?? {};
                          String fullName = '${basicInfo['firstName']} ${basicInfo['lastName']}';
                          return DropdownMenuItem<String>(
                            value: fullName, // Folosește numele complet ca valoare unică
                            child: Text(fullName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPerson = value;
                            var selectedPersonData = favoritePeople.firstWhere((person) {
                              Map<String, dynamic> basicInfo = person['basic_info'] ?? {};
                              return '${basicInfo['firstName']} ${basicInfo['lastName']}' == value;
                            });
                            _populateFields(selectedPersonData);
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Te rog selectează o persoană';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                ),
              ),
              Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Nume',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Te rog introdu numele tău';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Adresă',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: address,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Te rog introdu adresa de livrare';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            address = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Număr de telefon',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: phoneNumber,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Te rog introdu numărul de telefon';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            phoneNumber = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Observații',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          setState(() {
                            observations = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
      Text('Total de plată: \$${widget.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitOrderAndPay, // Apelăm funcția care face plata și trimite comanda
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text('Plătește cu cardul', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
