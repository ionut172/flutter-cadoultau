import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/order.dart' as model; // Folosim un alias pentru modelul nostru de Order
import 'package:cadoultau/src/themes/light_color.dart';

class MyOrdersPage extends StatefulWidget {
  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  // Obține comenzile utilizatorului curent
  Stream<List<model.Order>> getOrdersForCurrentUser() {
    if (currentUser == null) {
      throw Exception('Utilizator neautentificat');
    }

    return FirebaseFirestore.instance
        .collection('orders')
        .where('userEmail', isEqualTo: currentUser!.email)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => model.Order.fromMap(doc.data())).toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comenzile Mele'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<List<model.Order>>(
        stream: getOrdersForCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Eroare la încărcarea comenzilor.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nu aveți comenzi plasate.'));
          }

          List<model.Order> orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Center( // Am adăugat Center pentru a centra cardurile
                child: OrderCard(order: order), // Card pentru fiecare comandă
              );
            },
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final model.Order order; // Folosim model.Order

  OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
          children: [
            Text(
              order.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center icons and text
              children: [
                Icon(Icons.location_on, size: 16, color: LightColor.lightBlue),
                SizedBox(width: 5),
                Text(order.address),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, size: 16, color: LightColor.lightBlue),
                SizedBox(width: 5),
                Text(order.phoneNumber),
              ],
            ),
            SizedBox(height: 10),
            if (order.observations.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note, size: 16, color: LightColor.lightBlue),
                  SizedBox(width: 5),
                  Text('Observații: ${order.observations}'),
                ],
              ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 16, color: LightColor.lightBlue),
                SizedBox(width: 5),
                Text(order.selectedPersonId ?? 'Persoană nespecificată'),
              ],
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  // Poți adăuga funcționalitate pentru vizualizarea detaliilor comenzii
                },
                child: Text('Detalii'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LightColor.lightBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
