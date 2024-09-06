import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/cart_data.dart'; // Import the global cart list
import 'shopping_cart_page.dart';  // Make sure the path is correct
import '../model/activity.dart';  // Import the Activity model

class ActivitiesPage extends StatefulWidget {
  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  List<dynamic> activities = [];

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      setState(() {
        activities = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load activities');
    }
  }

  void addToCart(Map<String, dynamic> activityData) {
  Activity activity = Activity(
    id: activityData['id'],
    title: activityData['title'],
    category: activityData['category'],
    description: activityData['description'],
    image: activityData['image'],
    price: (activityData['price'] as num).toDouble(),
    quantity: 1,  // Cantitatea implicită este 1
  );

  setState(() {
    cartList.add(activity); // Adaugă obiectul de tip 'Activity' în cart
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activități'),
      ),
      body: activities.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          activity['image'],
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 10),
                        Text(
                          activity['title'],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '\$${activity['price']}',
                          style: TextStyle(fontSize: 16, color: Colors.green),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            addToCart(activity);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${activity['title']} a fost adăugat în coș'),
                              ),
                            );
                          },
                          child: Text('Adaugă în coș'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ShoppingCartPage(cartList: cartList)),
          );
        },
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}
