import 'package:flutter/material.dart';

class Order {
  final String name;
  final String address;
  final String phoneNumber;
  final String? selectedPersonId; // Persoana favorită selectată (opțional)
  final String observations;
  final String userEmail; // Emailul utilizatorului care face comanda

  Order({
    required this.name,
    required this.address,
    required this.phoneNumber,
    this.observations = "",
    this.selectedPersonId,
    required this.userEmail, // Emailul este acum obligatoriu
  });

  // Metodă pentru a converti un Order într-un Map pentru a fi salvat în Firestore sau altă bază de date
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'selectedPersonId': selectedPersonId,
      'observations': observations,
      'userEmail': userEmail, // Include emailul în map
    };
  }

  // Metodă statică pentru a crea un obiect Order dintr-un Map (de ex. când citim date din Firestore)
  static Order fromMap(Map<String, dynamic> map) {
    return Order(
      name: map['name'],
      address: map['address'],
      phoneNumber: map['phoneNumber'],
      selectedPersonId: map['selectedPersonId'],
      observations: map['observations'],
      userEmail: map['userEmail'], // Preia emailul din map
    );
  }
}
